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

BATCH_SIZE = 10000  # Ajuste conforme memória e desempenho

def inserir_pessoa(caminho_arquivo):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Conectado ao banco com sucesso.")
    except Exception as e:
        print(f"❌ Erro na conexão: {e}")
        return

    try:
        with open(caminho_arquivo, 'r', encoding='latin1') as f:
            linhas = f.readlines()
    except Exception as e:
        print(f"❌ Erro ao ler o arquivo: {e}")
        return

    registros = []
    inseridas = 0
    ignoradas = 0

    for linha in tqdm(linhas, desc="🔄 Inserindo pessoas", unit="linha"):
        partes = linha.strip().split("##")

        if len(partes) != 2:
            ignoradas += 1
            continue

        pessoaID, nome = partes

        try:
            pessoaID = int(pessoaID)
        except Exception:
            ignoradas += 1
            continue

        registros.append((pessoaID, nome))

        if len(registros) >= BATCH_SIZE:
            try:
                execute_values(cursor, """
                    INSERT INTO raw_data.Pessoa (pessoaID, nome)
                    VALUES %s
                    ON CONFLICT (pessoaID) DO NOTHING
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
                INSERT INTO raw_data.Pessoa (pessoaID, nome)
                VALUES %s
                ON CONFLICT (pessoaID) DO NOTHING
            """, registros)
            conn.commit()
            inseridas += len(registros)
        except Exception as e:
            conn.rollback()
            print(f"❌ Erro ao inserir último lote: {e}")
            ignoradas += len(registros)

    cursor.close()
    conn.close()
    print(f"\n✅ Inserção concluída. {inseridas} inseridas, {ignoradas} ignoradas.")

if __name__ == "__main__":
    inserir_pessoa('pessoa.txt')
