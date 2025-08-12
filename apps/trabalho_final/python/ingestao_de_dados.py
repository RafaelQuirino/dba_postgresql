import os
import psycopg2
from tqdm import tqdm
import re

BATCH_SIZE = 15000
DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def conectar_banco():
    print(f"Conectando ao banco: {DB_CONFIG['database']}…")
    return psycopg2.connect(**DB_CONFIG)

def contar_linhas(arquivo):
    with open(arquivo, 'r', encoding='iso-8859-1') as f:
        return sum(1 for _ in f)

def processar_linha(linha, colunas_minimas):
    dados = linha.strip().split('##')
    if len(dados) < colunas_minimas:
        return None
    return dados

def executar_insercao(conn, cursor, sql_insert, valores, log_erro, linha_original, linha_numero):
    try:
        cursor.execute(sql_insert, valores)
        return True
    except Exception as e:
        conn.rollback()
        log_erro.write(f"[L{linha_numero}] erro: {linha_original.strip()} → {e}\n")
        return False

def processar_arquivo(conn, arquivo, sql_insert, colunas_minimas, montar_valores, verify=None):
    cursor = conn.cursor()
    linhas_completas = 0
    inserts_pendentes = 0
    erros_path = arquivo.replace(".txt", "_erro.txt")
    total_linhas = contar_linhas(arquivo)

    with open(arquivo, 'r', encoding='iso-8859-1') as f, \
         open(erros_path, 'w', encoding='utf-8') as log_erro:

        for i, linha in enumerate(tqdm(f, total=total_linhas, desc=f"Processando {os.path.basename(arquivo)}", unit="linha")):
            dados = processar_linha(linha, colunas_minimas)
            if not dados:
                log_erro.write(f"[L{i+1}] colunas insuficientes: {linha}")
                continue

            if verify and not verify(cursor, dados):
                log_erro.write(f"[L{i+1}] verificação falhou: {linha}")
                continue

            valores = montar_valores(dados)
            sucesso = executar_insercao(conn, cursor, sql_insert, valores, log_erro, linha, i+1)

            if sucesso:
                linhas_completas += 1
                inserts_pendentes += 1

            if inserts_pendentes >= BATCH_SIZE:
                conn.commit()
                inserts_pendentes = 0

        if inserts_pendentes:
            conn.commit()

    cursor.close()
    return linhas_completas, total_linhas, erros_path

def inserir_dados(arquivo, sql_insert, colunas_minimas, montar_valores, verify=None):
    print(f"\nLendo arquivo: {arquivo}")
    conn = conectar_banco()
    
    try:
        linhas_completas, total_linhas, erros_path = processar_arquivo(
            conn, arquivo, sql_insert, colunas_minimas, montar_valores, verify
        )
        print(f"{linhas_completas} linhas processadas de {total_linhas}.")
        print(f"Erros em: {erros_path}")
    finally:
        conn.close()

def limpar_numerico(valor):
    if valor is None:
        return None

    valor_str = str(valor).strip().lower()
    if valor_str in ["null", "none", ""]:
        return None

    numeros = re.sub(r'\D', '', valor_str)
    return int(numeros) if numeros else None

def verificar_pessoa_e_producao(cursor, dados):
    pessoa_id = limpar_numerico(dados[0])
    producao_id = limpar_numerico(dados[1])

    cursor.execute("SELECT 1 FROM raw_data.pessoas WHERE pessoa_id = %s", (pessoa_id,))
    if not cursor.fetchone():
        return False

    cursor.execute("SELECT 1 FROM raw_data.producoes WHERE producao_id = %s", (producao_id,))
    return cursor.fetchone() is not None

if __name__ == "__main__":
    inserir_dados(
        '/app/pessoa.txt',
        """
        INSERT INTO raw_data.pessoas (pessoa_id, nome)
        VALUES (%s, %s)
        ON CONFLICT (pessoa_id) DO NOTHING
        """,
        colunas_minimas=2,
        montar_valores=lambda d: (limpar_numerico(d[0]), d[1])
    )

    inserir_dados(
        '/app/producao.txt',
        """
        INSERT INTO raw_data.producoes (producao_id, titulo, ano, tipo_id)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (producao_id) DO NOTHING
        """,
        colunas_minimas=4,
        montar_valores=lambda d: (
            limpar_numerico(d[0]),
            d[1],
            limpar_numerico(d[2]),
            limpar_numerico(d[3])
        )
    )

    inserir_dados(
        '/app/equipe.txt',
        """
        INSERT INTO raw_data.equipes (pessoa_id, producao_id, papel)
        VALUES (%s, %s, %s)
        ON CONFLICT (pessoa_id, producao_id) DO NOTHING
        """,
        colunas_minimas=3,
        montar_valores=lambda d: (
            limpar_numerico(d[0]),
            limpar_numerico(d[1]),
            d[2]
        ),
        verify=verificar_pessoa_e_producao
    )