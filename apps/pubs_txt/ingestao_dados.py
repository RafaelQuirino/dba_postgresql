import psycopg2
import os
from psycopg2 import sql
import io
import re
import tempfile

# Dados de conexão com o banco de dados
DB_HOST = os.getenv("DB_HOST", "postgresql")
DB_NAME = os.getenv("DB_NAME", "cinetech_productions")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("POSTGRES_PASSWORD", os.getenv("DB_PASSWORD", "postgres123"))
DB_SCHEMA = os.getenv("DB_SCHEMA", "raw_data")

# Caminho dos arquivos de dados dentro do contêiner
data_path = "/app"

# Conecta ao banco de dados
try:
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        client_encoding='LATIN1'
    )
    cur = conn.cursor()
    print("Conexao com o banco de dados estabelecida com sucesso.")
    # Diagnóstico do ambiente de conexão
    cur.execute("select current_database(), current_user, inet_server_addr(), version()")
    db, usr, host_addr, ver = cur.fetchone()
    print(f"Diagnostico: database={db}, user={usr}, host_addr={host_addr}")
    print(ver.split('\n')[0])
except (Exception, psycopg2.Error) as error:
    print("Erro ao conectar ao PostgreSQL:", error)
    exit()

def quote_ident_if_needed(identifier: str) -> str:
    """
    Retorna o identificador com aspas duplas se contiver caracteres especiais
    (ex.: espaço) ou letras maiúsculas. Caso contrário, retorna sem aspas.
    """
    # Aspas dentro do nome (raro) precisam ser duplicadas para serem válidas em SQL
    sanitized = identifier.replace('"', '""')
    needs_quotes = (sanitized != sanitized.lower()) or any(ch not in "abcdefghijklmnopqrstuvwxyz0123456789_" for ch in sanitized)
    return f'"{sanitized}"' if needs_quotes else sanitized

def make_table_name(schema: str, table: str) -> str:
    return f"{quote_ident_if_needed(schema)}.{quote_ident_if_needed(table)}"

def ingest_data_copy_from(file_name, table_name, columns):
    file_path = os.path.join(data_path, file_name)
    print(f"Iniciando a ingestao de dados de {file_name} para a tabela {table_name}...")
    # Confirma se a tabela existe antes do COPY
    try:
        cur.execute("select to_regclass(%s)", (table_name,))
        reg = cur.fetchone()[0]
        print(f"Checagem existencia: to_regclass('{table_name}') = {reg}")
    except Exception as e:
        print(f"Falha ao checar existencia de {table_name}: {e}")
    
    # Monta COPY usando composicao segura de identificadores (schema, tabela, colunas)
    def _split_schema_table(full_name: str):
        # Suporta formas como raw_data.producao ou "raw data"."Producao"
        if '.' not in full_name:
            return None, full_name
        schema_part, table_part = full_name.split('.', 1)
        return schema_part.strip('"'), table_part.strip('"')

    schema_part, table_part = _split_schema_table(table_name)

    # Resolve nomes reais das colunas no catálogo, de forma case-insensitive
    def _resolve_columns(real_schema: str, real_table: str, desired_cols):
        try:
            qname = f'{quote_ident_if_needed(real_schema)}.{quote_ident_if_needed(real_table)}'
            cur.execute("""
                select a.attname
                  from pg_attribute a
                  join pg_class c on c.oid = a.attrelid
                  join pg_namespace n on n.oid = c.relnamespace
                 where n.nspname = %s
                   and c.relname = %s
                   and a.attnum > 0 and not a.attisdropped
            """, (real_schema, real_table))
            existing = [r[0] for r in cur.fetchall()]
            mapping = {e.lower(): e for e in existing}
            resolved = []
            for d in desired_cols:
                key = d.lower()
                if key in mapping:
                    resolved.append(mapping[key])
                else:
                    # fallback: usar minúsculo do desejado
                    resolved.append(key)
            if [c for c in resolved] != desired_cols:
                print(f"Colunas ajustadas para tabela {qname}: {resolved}")
            return resolved
        except Exception as e:
            print(f"Falha ao resolver colunas para {real_schema}.{real_table}: {e}")
            return [c.lower() for c in desired_cols]

    resolved_columns = _resolve_columns(schema_part or DB_SCHEMA, table_part, columns)

    columns_ident_list = [sql.Identifier(c) for c in resolved_columns]
    columns_sql = sql.SQL(', ').join(columns_ident_list)
    # Estratégia robusta: COPY para tabela temporária (tudo TEXT), depois INSERT com CAST e ON CONFLICT DO NOTHING
    tmp_table = f"tmp_{table_part}_{os.getpid()}"
    tmp_ident = sql.Identifier(tmp_table)
    target_schema_ident = sql.Identifier(schema_part) if schema_part else sql.Identifier(DB_SCHEMA)
    target_table_ident = sql.Identifier(table_part)

    # 1) Criar tabela temporária com colunas TEXT
    create_cols_sql = sql.SQL(', ').join([sql.SQL("{} TEXT").format(sql.Identifier(c)) for c in resolved_columns])
    create_tmp_stmt = sql.SQL("CREATE TEMP TABLE {} ({}) ON COMMIT DROP").format(tmp_ident, create_cols_sql)

    # 2) COPY para a tabela temporária com delimitador TAB e NULL 'null'
    copy_tmp_stmt = sql.SQL("COPY {} ({}) FROM STDIN WITH (FORMAT text, DELIMITER E'\\t', NULL 'null')").format(
        tmp_ident,
        columns_sql
    )

    # 3) Descobrir tipos das colunas alvo para aplicar CASTs
    cur.execute(
        """
        select column_name, data_type
          from information_schema.columns
         where table_schema = %s and table_name = %s
        """,
        (schema_part or DB_SCHEMA, table_part)
    )
    type_map = {r[0]: r[1] for r in cur.fetchall()}

    # 4) Montar SELECT com casts apropriados
    select_exprs = []
    for c in resolved_columns:
        dtype = (type_map.get(c) or '').lower()
        id_c = sql.Identifier(c)
        if any(t in dtype for t in ["integer", "smallint", "bigint"]):
            # remove tudo que não for digito ou sinal e faz cast
            expr = sql.SQL("NULLIF(regexp_replace({col}, '[^0-9-]', '', 'g'), '')::integer").format(col=id_c)
        elif any(t in dtype for t in ["double", "real", "numeric", "decimal"]):
            expr = sql.SQL("NULLIF(regexp_replace({col}, '[^0-9eE+\-.]', '', 'g'), '')::numeric").format(col=id_c)
        else:
            expr = id_c
        select_exprs.append(expr)
    select_list_sql = sql.SQL(', ').join(select_exprs)

    insert_stmt = sql.SQL("""
        INSERT INTO {}.{} ({})
        SELECT {} FROM {}
        ON CONFLICT DO NOTHING
    """).format(
        target_schema_ident,
        target_table_ident,
        columns_sql,
        select_list_sql,
        tmp_ident
    )

    try:
        # Cria temp table
        cur.execute(create_tmp_stmt)

        # 0) Contar total de linhas para calcular percentual
        total_linhas = 0
        with open(file_path, 'r', encoding='latin1') as fcnt:
            for _ in fcnt:
                total_linhas += 1
        if total_linhas == 0:
            print(f"{file_name}: arquivo vazio. Nada a carregar.")
            return

        # 1) Pré-processar para arquivo temporário com progressão percentual
        expected_cols = len(resolved_columns)
        tmp_fd, tmp_path = tempfile.mkstemp(prefix=f"ing_{table_part}_", suffix=".tsv")
        os.close(tmp_fd)  # vamos reabrir como texto
        processed = 0
        next_mark = 0  # próximo percentual a imprimir
        with open(file_path, 'r', encoding='latin1') as fin, open(tmp_path, 'w', encoding='latin1', newline='') as fout:
            for raw_line in fin:
                # transformar delimitadores '##' (2+ '#') em TAB
                line = re.sub(r"#{2,}", "\t", raw_line.rstrip("\n\r"))
                parts = line.split('\t') if line != '' else ['']
                if len(parts) > expected_cols:
                    # Unir o excedente com ESPAÇO (não usar TAB, para não criar delimitadores extras)
                    parts = parts[:expected_cols-1] + [' '.join(parts[expected_cols-1:])]
                elif len(parts) < expected_cols:
                    parts = parts + [''] * (expected_cols - len(parts))
                fout.write('\t'.join(parts) + '\n')
                processed += 1
                # imprimir a cada 5%
                if total_linhas:
                    pct = int(processed * 100 / total_linhas)
                    if pct >= next_mark:
                        print(f"{file_name}: preparando dados {pct}% ({processed}/{total_linhas})")
                        next_mark += 5

        # 2) COPY para temp
        print(f"{file_name}: copiando para tabela temporaria...")
        with open(tmp_path, 'r', encoding='latin1') as buf:
            cur.copy_expert(copy_tmp_stmt, buf)
        print(f"{file_name}: COPY concluido.")

        # 3) Inserir no destino com casts e ignorando duplicatas
        print(f"{file_name}: inserindo na tabela de destino...")
        cur.execute(insert_stmt)
        inseridas = cur.rowcount if cur.rowcount is not None else 0
        print(f"{file_name}: inseridas {inseridas} linhas (de {total_linhas}).")

        conn.commit()
        print(f"Ingestao de dados de {file_name} concluida com sucesso.")
        try:
            os.remove(tmp_path)
        except Exception:
            pass
    except FileNotFoundError:
        print(f"Erro: O arquivo {file_path} nao foi encontrado.")
    except Exception as e:
        conn.rollback()
        print(f"Erro durante a ingestao de {file_name}: {e}")

# Definição das tabelas e arquivos para ingestão
ingest_config = [
    {
        'file': 'producao.txt',
        'table': make_table_name(DB_SCHEMA, 'producao'),
        'columns': ['producaoID', 'titulo', 'ano_producao', 'tipo_ID']
    },
    {
        'file': 'pessoa.txt',
        'table': make_table_name(DB_SCHEMA, 'pessoa'),
        'columns': ['pessoaID', 'nome']
    },
    {
        'file': 'equipe.txt',
        'table': make_table_name(DB_SCHEMA, 'equipe'),
        'columns': ['pessoaID', 'producaoID', 'papel']
    }
]

# Executa a ingestão para cada arquivo
for config in ingest_config:
    ingest_data_copy_from(config['file'], config['table'], config['columns'])

# Fecha a conexão com o banco de dados
cur.close()
conn.close()