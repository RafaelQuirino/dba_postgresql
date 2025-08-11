import psycopg2
from psycopg2.extras import execute_values
import os

# Configurações do banco
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "cinetech_productions",
    "user": "postgres",
    "password": "postgres123"
}

# Caminhos dos arquivos
DATA_PATH = "/data"  # ajuste conforme local dos arquivos
FILES = {
    "producao": "producao.txt",
    "pessoa": "pessoa.txt",
    "equipe": "equipe.txt"
}

BATCH_SIZE = 10000

import os

def connect_db():
    host = os.getenv("DB_HOST", "localhost")
    dbname = os.getenv("DB_NAME", "cinetech_productions")
    user = os.getenv("DB_USER", "postgres")
    password = os.getenv("DB_PASSWORD", "postgres123")
    port = int(os.getenv("DB_PORT", 5432))

    conn = psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password,
        port=port
    )
    return conn


def ingest_producao(conn):
    print("Iniciando ingestão - producao.txt")
    file_path = os.path.join(DATA_PATH, FILES["producao"])
    with open(file_path, encoding="utf-8") as f, conn.cursor() as cur:
        batch = []
        total = 0
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            parts = line.split("##")
            if len(parts) != 4:
                print(f"[WARNING] Linha {line_num} mal formatada em producao.txt: {line}")
                continue
            id_producao, titulo, ano_producao, tipo_id = parts
            try:
                batch.append((int(id_producao), titulo, int(ano_producao), int(tipo_id)))
            except Exception as e:
                print(f"[ERROR] Conversão falhou na linha {line_num} producao.txt: {e}")
                continue
            if len(batch) >= BATCH_SIZE:
                execute_values(cur,
                               "INSERT INTO raw_data.producao (id_producao, titulo, ano_producao, tipo_id) VALUES %s ON CONFLICT (id_producao) DO NOTHING",
                               batch)
                conn.commit()
                total += len(batch)
                print(f"Inseridos {total} registros em producao")
                batch.clear()
        # Inserir o que sobrou
        if batch:
            execute_values(cur,
                           "INSERT INTO raw_data.producao (id_producao, titulo, ano_producao, tipo_id) VALUES %s ON CONFLICT (id_producao) DO NOTHING",
                           batch)
            conn.commit()
            total += len(batch)
            print(f"Inseridos {total} registros em producao")
    print("Ingestão producao.txt concluída")

def ingest_pessoa(conn):
    print("Iniciando ingestão - pessoa.txt")
    file_path = os.path.join(DATA_PATH, FILES["pessoa"])
    with open(file_path, encoding="latin1") as f, conn.cursor() as cur:
        batch = []
        total = 0
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            parts = line.split("##")
            if len(parts) != 2:
                print(f"[WARNING] Linha {line_num} mal formatada em pessoa.txt: {line}")
                continue
            id_pessoa, nome = parts
            try:
                batch.append((int(id_pessoa), nome))
            except Exception as e:
                print(f"[ERROR] Conversão falhou na linha {line_num} pessoa.txt: {e}")
                continue
            if len(batch) >= BATCH_SIZE:
                execute_values(cur,
                               "INSERT INTO raw_data.pessoa (id_pessoa, nome) VALUES %s ON CONFLICT (id_pessoa) DO NOTHING",
                               batch)
                conn.commit()
                total += len(batch)
                print(f"Inseridos {total} registros em pessoa")
                batch.clear()
        if batch:
            execute_values(cur,
                           "INSERT INTO raw_data.pessoa (id_pessoa, nome) VALUES %s ON CONFLICT (id_pessoa) DO NOTHING",
                           batch)
            conn.commit()
            total += len(batch)
            print(f"Inseridos {total} registros em pessoa")
    print("Ingestão pessoa.txt concluída")

def ingest_equipe(conn):
    print("Iniciando ingestão - equipe.txt")

    # Carregar ids válidos de producao
    with conn.cursor() as cur:
        cur.execute("SELECT id_producao FROM raw_data.producao")
        producao_ids = set(row[0] for row in cur.fetchall())

        cur.execute("SELECT id_pessoa FROM raw_data.pessoa")
        pessoa_ids = set(row[0] for row in cur.fetchall())

    file_path = os.path.join(DATA_PATH, FILES["equipe"])
    with open(file_path, encoding="latin1") as f, conn.cursor() as cur:
        batch = []
        total = 0
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            parts = line.split("##")
            if len(parts) != 3:
                print(f"[WARNING] Linha {line_num} mal formatada em equipe.txt: {line}")
                continue
            try:
                id_pessoa, id_producao, papel = parts
                id_pessoa = int(id_pessoa)
                id_producao = int(id_producao)

                # Verifica FK antes de adicionar
                if id_producao not in producao_ids:
                    print(f"[SKIP] Linha {line_num} ignorada: id_producao {id_producao} não existe")
                    continue
                if id_pessoa not in pessoa_ids:
                    print(f"[SKIP] Linha {line_num} ignorada: id_pessoa {id_pessoa} não existe")
                    continue

                batch.append((id_pessoa, id_producao, papel))
            except Exception as e:
                print(f"[ERROR] Conversão falhou na linha {line_num} equipe.txt: {e}")
                continue
            if len(batch) >= BATCH_SIZE:
                execute_values(cur,
                               "INSERT INTO raw_data.equipe (id_pessoa, id_producao, papel) VALUES %s ON CONFLICT (id_pessoa, id_producao) DO NOTHING",
                               batch)
                conn.commit()
                total += len(batch)
                print(f"Inseridos {total} registros em equipe")
                batch.clear()
        if batch:
            execute_values(cur,
                           "INSERT INTO raw_data.equipe (id_pessoa, id_producao, papel) VALUES %s ON CONFLICT (id_pessoa, id_producao) DO NOTHING",
                           batch)
            conn.commit()
            total += len(batch)
            print(f"Inseridos {total} registros em equipe")
    print("Ingestão equipe.txt concluída")


def main():
    print("Conectando ao banco de dados...")
    conn = connect_db()
    try:
        ingest_producao(conn)
        ingest_pessoa(conn)
        ingest_equipe(conn)
    except Exception as e:
        print(f"[FATAL] Erro durante ingestão: {e}")
    finally:
        conn.close()
        print("Conexão ao banco encerrada.")

if __name__ == "__main__":
    main()