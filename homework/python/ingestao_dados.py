import os
import time
import pandas as pd
from sqlalchemy import create_engine, text
from tqdm import tqdm

# =============================
# Variáveis de ambiente (Docker)
# =============================
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

engine_url = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# =============================
# Retry: aguarda o banco ficar pronto
# =============================
print("Tentando conectar ao banco de dados...")
for attempt in range(10):
    try:
        engine = create_engine(engine_url)
        with engine.connect() as conn:
            print("Conexão estabelecida com sucesso!")
        break
    except Exception as e:
        print(f"Tentativa {attempt+1}/10 falhou: {e}")
        time.sleep(5)
else:
    raise Exception("Não foi possível conectar ao banco após 10 tentativas.")

# =============================
# Caminhos dos arquivos Parquet
# =============================
PARQUET_PATHS = {
    "producao": "/data/producao_filtrado.parquet",
    "pessoa": "/data/pessoa.parquet",
    "equipe": "/data/equipe.parquet"
}

# =============================
# Criação de schema e tabelas
# =============================
with engine.begin() as conn:
    print("Criando schema e tabelas...")
    conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw_data"))

    conn.execute(text("""
        CREATE TABLE IF NOT EXISTS raw_data.producao (
            id_producao BIGINT PRIMARY KEY,
            titulo TEXT,
            ano INT,
            tipo_id TEXT,
            quantidade INT
        )
    """))

    conn.execute(text("""
        CREATE TABLE IF NOT EXISTS raw_data.pessoa (
            id_pessoa BIGINT PRIMARY KEY,
            nome TEXT
        )
    """))

    conn.execute(text("""
        CREATE TABLE IF NOT EXISTS raw_data.equipe (
            id_pessoa BIGINT,
            id_producao BIGINT,
            papel TEXT,
            PRIMARY KEY (id_pessoa, id_producao),
            FOREIGN KEY (id_pessoa) REFERENCES raw_data.pessoa(id_pessoa),
            FOREIGN KEY (id_producao) REFERENCES raw_data.producao(id_producao)
        )
    """))

# =============================
# Função para inserir dados
# =============================
def insert_dataframe(df, table):
    print(f"Inserindo dados na tabela {table} ({len(df)} registros)")
    chunks = [df[i:i+10000] for i in range(0, len(df), 10000)]
    with engine.begin() as conn:
        for chunk in tqdm(chunks, desc=f"Inserindo {table}"):
            chunk.to_sql(table, conn, schema="raw_data", if_exists="append", index=False, method="multi")

# =============================
# Carregamento e Ingestão
# =============================
print("Lendo arquivos .parquet...")

# Produção
df_producao = pd.read_parquet(PARQUET_PATHS["producao"]).drop_duplicates(subset="id_producao")
print("Limpando colunas da produção...")
df_producao["ano"] = pd.to_numeric(df_producao["ano"], errors="coerce")
df_producao = df_producao.dropna(subset=["ano"])
df_producao["ano"] = df_producao["ano"].astype(int)
insert_dataframe(df_producao, "producao")

# Pessoa
df_pessoa = pd.read_parquet(PARQUET_PATHS["pessoa"]).drop_duplicates(subset="id_pessoa")
insert_dataframe(df_pessoa, "pessoa")

# Equipe
df_equipe = pd.read_parquet(PARQUET_PATHS["equipe"]).drop_duplicates(subset=["id_pessoa", "id_producao"])
# Verifica se referências existem nas tabelas principais
ids_validos_producao = set(df_producao["id_producao"])
ids_validos_pessoa = set(df_pessoa["id_pessoa"])
df_equipe = df_equipe[df_equipe["id_producao"].isin(ids_validos_producao)]
df_equipe = df_equipe[df_equipe["id_pessoa"].isin(ids_validos_pessoa)]
insert_dataframe(df_equipe, "equipe")

print("Ingestão finalizada com sucesso!")
