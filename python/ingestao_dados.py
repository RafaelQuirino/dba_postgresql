import os
import sys
import io
import time
from tqdm import tqdm
from dotenv import load_dotenv
import psycopg2
from psycopg2.extras import execute_batch

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "cinetech_productions")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres123")

DATA_DIR = os.getenv("DATA_DIR", "./data")
ARQ_PRODUCAO = os.path.join(DATA_DIR, "producao.txt")
ARQ_PESSOA   = os.path.join(DATA_DIR, "pessoa.txt")
ARQ_EQUIPE   = os.path.join(DATA_DIR, "equipe.txt")

OLD_DELIM = "##"
NEW_DELIM = "\x1f" 
ENC = "cp1252"

DDL_STAGING = """
CREATE SCHEMA IF NOT EXISTS staging;
DROP TABLE IF EXISTS staging.producao;
DROP TABLE IF EXISTS staging.pessoa;
DROP TABLE IF EXISTS staging.equipe;

CREATE TABLE staging.producao(producao_id TEXT, titulo TEXT, ano_producao TEXT, tipo_id TEXT);
CREATE TABLE staging.pessoa(pessoa_id TEXT, nome TEXT);
CREATE TABLE staging.equipe(pessoa_id TEXT, producao_id TEXT, papel TEXT);
"""

DDL_RAW = """
CREATE SCHEMA IF NOT EXISTS raw_data;
CREATE TABLE IF NOT EXISTS raw_data.producao(producao_id BIGINT PRIMARY KEY, titulo TEXT NOT NULL, ano_producao  INT CHECK (ano_producao BETWEEN 1870 AND EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1), tipo_id INT);
CREATE TABLE IF NOT EXISTS raw_data.pessoa(pessoa_id BIGINT PRIMARY KEY, nome TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS raw_data.equipe(pessoa_id BIGINT REFERENCES raw_data.pessoa(pessoa_id), producao_id BIGINT REFERENCES raw_data.producao(producao_id), papel TEXT, PRIMARY KEY (pessoa_id, producao_id));
"""

# ########################################################################## #
# ALTERAÇÃO FINAL: Adicionado filtro para ano_producao inválido
# ########################################################################## #
SQL_LOAD_TO_RAW = """
-- Produção
INSERT INTO raw_data.producao(producao_id,titulo,ano_producao,tipo_id)
SELECT DISTINCT
  NULLIF(BTRIM(s.producao_id),'')::BIGINT AS producao_id,
  NULLIF(BTRIM(s.titulo),'') AS titulo,
  NULLIF(REGEXP_REPLACE(s.ano_producao, '[^0-9]', '', 'g'),'')::INT AS ano_producao,
  NULLIF(REGEXP_REPLACE(s.tipo_id, '[^0-9]', '', 'g'),'')::INT AS tipo_id
FROM staging.producao s
WHERE 
  BTRIM(s.producao_id) ~ '^[0-9]+$' AND 
  BTRIM(s.titulo) <> '' AND
  NULLIF(REGEXP_REPLACE(s.ano_producao, '[^0-9]', '', 'g'),'')::INT >= 1870
ON CONFLICT (producao_id) DO NOTHING;

-- Pessoa
INSERT INTO raw_data.pessoa(pessoa_id,nome)
SELECT DISTINCT
  NULLIF(BTRIM(s.pessoa_id),'')::BIGINT AS pessoa_id,
  NULLIF(BTRIM(s.nome),'') AS nome
FROM staging.pessoa s
WHERE BTRIM(s.pessoa_id) ~ '^[0-9]+$' AND BTRIM(s.nome) <> ''
ON CONFLICT (pessoa_id) DO NOTHING;

-- Equipe (apenas FK válidas)
INSERT INTO raw_data.equipe(pessoa_id,producao_id,papel)
SELECT DISTINCT
  e.pessoa_id::BIGINT,
  e.producao_id::BIGINT,
  e.papel
FROM staging.equipe e
JOIN raw_data.producao p ON p.producao_id = e.producao_id::BIGINT
JOIN raw_data.pessoa   pe ON pe.pessoa_id = e.pessoa_id::BIGINT
ON CONFLICT (pessoa_id,producao_id) DO NOTHING;
"""

IDX_BASE = """
CREATE INDEX IF NOT EXISTS ix_producao_tipo ON raw_data.producao(tipo_id);
CREATE INDEX IF NOT EXISTS ix_producao_ano  ON raw_data.producao(ano_producao);
CREATE INDEX IF NOT EXISTS ix_equipe_prod   ON raw_data.equipe(producao_id);
CREATE INDEX IF NOT EXISTS ix_equipe_pess   ON raw_data.equipe(pessoa_id);
"""

def connect():
    return psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD)

def run_sql(cur, sql):
    for command in sql.split(';'):
        if command.strip():
            cur.execute(command)

def count_lines(path):
    with open(path, "r", encoding=ENC, errors="replace") as f:
        return sum(1 for _ in f)

def _expected_cols(table):
    if table == "producao": return 4
    if table == "pessoa": return 2
    if table == "equipe": return 3
    raise ValueError("tabela desconhecida")

def chunked_copy(conn, path, table, columns, chunk_size=200_000):
    total = count_lines(path)
    rejects_path = f"{path}.{table}.rejects"
    rej = open(rejects_path, "w", encoding=ENC, errors="replace")
    exp_cols = _expected_cols(table)
    t_start = time.time()
    with open(path, "r", encoding=ENC, errors="replace") as f, conn.cursor() as cur:
        pbar = tqdm(total=total, desc=f"COPY {os.path.basename(path)} -> {table}")
        buf = io.StringIO()
        lines_in_buf, copied, rejected = 0, 0, 0
        def flush_buf():
            nonlocal buf, lines_in_buf, copied
            if lines_in_buf == 0: return
            buf.seek(0)
            copy_sql = (f"COPY staging.{table}({','.join(columns)}) FROM STDIN WITH (FORMAT text, DELIMITER E'{NEW_DELIM}', NULL '', HEADER false)")
            cur.copy_expert(copy_sql, buf)
            buf = io.StringIO()
            copied += lines_in_buf
            lines_in_buf = 0
        for line in f:
            if not line.endswith("\n"): line += "\n"
            if line.count(OLD_DELIM) != (exp_cols - 1):
                rej.write(line)
                rejected += 1
            else:
                buf.write(line.replace(OLD_DELIM, NEW_DELIM))
                lines_in_buf += 1
            pbar.update(1)
            if lines_in_buf >= chunk_size: flush_buf()
        if lines_in_buf > 0: flush_buf()
        pbar.close()
    rej.close()
    took = time.time() - t_start
    print(f"   -> {table}: copiadas {copied:,} linhas; rejeitadas {rejected:,} linhas; {took:.1f}s. Arquivo de rejeitos: {rejects_path}")

def main():
    t0 = time.time()
    with connect() as conn:
        conn.autocommit = False
        with conn.cursor() as cur:
            print(">> Criando staging e tabelas raw_data (se necessário)...")
            run_sql(cur, DDL_STAGING)
            run_sql(cur, DDL_RAW)
        conn.commit()
        print(">> Iniciando COPY por chunks...")
        chunked_copy(conn, ARQ_PRODUCAO, "producao", ["producao_id","titulo","ano_producao","tipo_id"])
        chunked_copy(conn, ARQ_PESSOA,   "pessoa",   ["pessoa_id","nome"])
        chunked_copy(conn, ARQ_EQUIPE,   "equipe",   ["pessoa_id","producao_id","papel"])
        conn.commit()
        print(">> Transferindo staging -> raw_data com validações...")
        with conn.cursor() as cur:
            run_sql(cur, SQL_LOAD_TO_RAW)
            run_sql(cur, IDX_BASE)
        conn.commit()
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM raw_data.producao"); n_prod = cur.fetchone()[0]
            cur.execute("SELECT COUNT(*) FROM raw_data.pessoa");   n_pes  = cur.fetchone()[0]
            cur.execute("SELECT COUNT(*) FROM raw_data.equipe");   n_eq   = cur.fetchone()[0]
        print(f">> FIM! producao={n_prod:,} | pessoa={n_pes:,} | equipe={n_eq:,}")
        print(f">> Tempo total: {time.time()-t0:.1f}s")

if __name__ == "__main__":
    miss = [p for p in [ARQ_PRODUCAO, ARQ_PESSOA, ARQ_EQUIPE] if not os.path.exists(p)]
    if miss:
        print("Arquivos faltando:", miss, file=sys.stderr)
        sys.exit(1)
    main()