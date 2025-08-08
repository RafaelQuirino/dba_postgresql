import os
import psycopg2
from psycopg2.extras import execute_values
from tqdm import tqdm

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'port': os.environ.get('DB_PORT', 5432),
    'database': 'cinetech_productions',
    'user': os.environ.get('DB_USER', 'postgres'),
    'password': os.environ.get('DB_PASSWORD', 'postgres123')
}

BATCH_SIZE = 10000

def inserir_dados_pessoa(caminho_arquivo):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Conexão com o banco estabelecida com sucesso.\n")
    except Exception as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}\n")
        return

    try:
        with open(caminho_arquivo, 'r', encoding='latin1') as f:
            linhas = f.readlines()
    except Exception as e:
        print(f"❌ Erro ao ler o arquivo: {e}")
        conn.close()
        return

    registros = []
    inseridas = 0
    ignoradas = 0

    for linha in tqdm(linhas, desc="🔄 Inserindo registros", unit="linha"):
        linha = linha.strip()
        if not linha:
            continue

        partes = linha.split("##")
        if len(partes) != 2:
            ignoradas += 1
            continue

        pessoaID, nome = partes

        try:
            pessoaID = int(pessoaID) if pessoaID.lower() != "null" else None
        except:
            ignoradas += 1
            continue

        nome = nome if nome.lower() != "null" else None

        if pessoaID is None or nome is None:
            ignoradas += 1
            continue

        registros.append((pessoaID, nome))

        if len(registros) >= BATCH_SIZE:
            try:
                execute_values(cursor, """
                    INSERT INTO raw_data.pessoa (pessoaID, nome)
                    VALUES %s
                    ON CONFLICT DO NOTHING
                """, registros)
                conn.commit()
                inseridas += len(registros)
                registros = []
            except Exception as e:
                conn.rollback()
                print(f"❌ Erro ao inserir lote: {e}")
                ignoradas += len(registros)
                registros = []

    # Inserir restantes
    if registros:
        try:
            execute_values(cursor, """
                INSERT INTO raw_data.pessoa (pessoaID, nome)
                VALUES %s
                ON CONFLICT DO NOTHING
            """, registros)
            conn.commit()
            inseridas += len(registros)
        except Exception as e:
            conn.rollback()
            print(f"❌ Erro ao inserir último lote: {e}")
            ignoradas += len(registros)

    cursor.close()
    conn.close()
    print(f"\n✅ Inserção finalizada.")
    print(f"👉 Registros inseridos: {inseridas}")
    print(f"🚫 Linhas ignoradas: {ignoradas}")

if __name__ == "__main__":
    inserir_dados_pessoa("pessoa.txt")