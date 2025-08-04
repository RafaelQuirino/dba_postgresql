import os
import re
from tqdm import tqdm
import psycopg2

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def inserir_pessoas(arquivo):
    print(f"\nLendo arquivo: {arquivo}")
    print(f"Conectando ao banco de dados {DB_CONFIG['database']}...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    with open(arquivo, 'r', encoding='iso-8859-1') as f:
        linhas = f.readlines()

    for i, linha in enumerate(tqdm(linhas[:10], desc=f"Processando {os.path.basename(arquivo)}", unit="linha")):
        print(linha.strip().split('##'))
        dados = linha.strip().split('##')
        if len(dados) < 2:
            print(f"Linha {i+1} ignorada: {linha.strip()}")
            continue
        try:
            cursor.execute(
                "INSERT INTO raw_data.pessoas (pessoa_id, nome) VALUES (%s, %s)",
                (dados[0], dados[1])
            )
        except Exception as e:
            print(f"Erro ao inserir linha {i+1}: {e}")
            continue
    conn.commit()
    cursor.close()
    conn.close()
    print(f"{len(linhas)} linhas inseridas com sucesso!")



def inserir_producao(arquivo):
    print(f"\nLendo arquivo: {arquivo}")
    print(f"Conectando ao banco de dados {DB_CONFIG['database']}...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    with open(arquivo, 'r', encoding='iso-8859-1') as f:
        linhas = f.readlines()

    for i, linha in enumerate(tqdm(linhas[:10], desc=f"Processando {os.path.basename(arquivo)}", unit="linha")):
        print(linha.strip().split('##'))
        dados = linha.strip().split('##')
        if len(dados) < 2:
            print(f"Linha {i+1} ignorada: {linha.strip()}")
            continue
        try:
            cursor.execute(
                "INSERT INTO raw_data.producoes (producao_id, titulo, ano, tipo_id) VALUES (%s, %s, %s, %s)",
                (dados[0], dados[1], dados[2], dados[3])
            )
        except Exception as e:
            print(f"Erro ao inserir linha {i+1}: {e}")
            continue
    conn.commit()
    cursor.close()
    conn.close()
    print(f"{len(linhas)} linhas inseridas com sucesso!")


def inserir_equipe(arquivo):
    print(f"\nLendo arquivo: {arquivo}")
    print(f"Conectando ao banco de dados {DB_CONFIG['database']}...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    with open(arquivo, 'r', encoding='iso-8859-1') as f:
        linhas = f.readlines()

    for i, linha in enumerate(tqdm(linhas[:10], desc=f"Processando {os.path.basename(arquivo)}", unit="linha")):
        print(linha.strip().split('##'))
        dados = linha.strip().split('##')
        if len(dados) < 3:
            print(f"Linha {i+1} ignorada: {linha.strip()}")
            continue
        try:
            cursor.execute(
                "INSERT INTO raw_data.equipes (pessoa_id, producao_id, papel) VALUES (%s, %s, %s)",
                (dados[0], dados[1], dados[2])
            )
        except Exception as e:
            print(f"Erro ao inserir linha {i+1}: {e}")
            continue
    conn.commit()
    cursor.close()
    conn.close()
    print(f"{len(linhas)} linhas inseridas com sucesso!")

if __name__ == "__main__":
    # inserir_pessoas('/app/pessoa.txt')
    # inserir_producao('/app/producao.txt')
    inserir_equipe('/app/equipe.txt')