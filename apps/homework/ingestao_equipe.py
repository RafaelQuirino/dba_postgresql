import os
import psycopg2
from psycopg2.extras import execute_values
from tqdm import tqdm

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'port': int(os.environ.get('DB_PORT', 5432)),
    'database': 'cinetech_productions',
    'user': os.environ.get('DB_USER', 'postgres'),
    'password': os.environ.get('DB_PASSWORD', 'postgres123')
}

BATCH_SIZE = 10000  # você pode ajustar se necessário

def inserir_dados_equipe(caminho_arquivo):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Conexão com o banco estabelecida com sucesso.\n")
    except Exception as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}\n")
        return

    # Buscar todos os pessoaID e producaoID válidos no banco
    try:
        cursor.execute("SELECT pessoaID FROM raw_data.pessoa")
        pessoas_validas = set(row[0] for row in cursor.fetchall())

        cursor.execute("SELECT producaoID FROM raw_data.producao")
        producoes_validas = set(row[0] for row in cursor.fetchall())

        print(f"ℹ️ Pessoas válidas: {len(pessoas_validas)}")
        print(f"ℹ️ Produções válidas: {len(producoes_validas)}\n")
    except Exception as e:
        print(f"❌ Erro ao buscar IDs válidos: {e}")
        conn.close()
        return

    try:
        with open(caminho_arquivo, 'r', encoding='latin1') as f:
            linhas = f.readlines()
    except Exception as e:
        print(f"❌ Erro ao ler o arquivo: {e}\n")
        conn.close()
        return

    registros = []
    inseridas = 0
    ignoradas = 0

    for linha in tqdm(linhas, desc="🔄 Inserindo registros", unit="linha"):
        linha = linha.strip()
        if not linha:
            continue

        partes = linha.split('##')
        if len(partes) != 3:
            ignoradas += 1
            continue

        pessoaID_raw, producaoID_raw, papel_raw = partes

        try:
            pessoaID = int(pessoaID_raw) if pessoaID_raw.lower() != 'null' else None
            producaoID = int(producaoID_raw) if producaoID_raw.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue

        papel = papel_raw if papel_raw.lower() != 'null' else None

        if pessoaID not in pessoas_validas or producaoID not in producoes_validas:
            ignoradas += 1
            continue

        registros.append((pessoaID, producaoID, papel))

        if len(registros) >= BATCH_SIZE:
            try:
                execute_values(cursor, """
                    INSERT INTO raw_data.equipe (pessoaID, producaoID, papel)
                    VALUES %s
                    ON CONFLICT (pessoaID, producaoID) DO NOTHING
                """, registros)
                conn.commit()
                inseridas += len(registros)
                registros = []
            except Exception as e:
                conn.rollback()
                print(f"❌ Erro ao inserir lote: {e}")
                ignoradas += len(registros)
                registros = []

    # Inserir registros restantes
    if registros:
        try:
            execute_values(cursor, """
                INSERT INTO raw_data.equipe (pessoaID, producaoID, papel)
                VALUES %s
                ON CONFLICT (pessoaID, producaoID) DO NOTHING
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
    inserir_dados_equipe('equipe.txt')