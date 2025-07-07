import os
import re
import psycopg2
from tqdm import tqdm

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def inserir_publicacoes(arquivo):
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    with open(arquivo, 'r', encoding='utf-8') as f:
        conteudo = f.read()

    publicacoes = re.split(r'-----###-----', conteudo)

    num_pubs = len(publicacoes)
    for pub in tqdm(publicacoes, desc="Processando pubs..."):
        pub = pub.strip()
        if pub:
            cursor.execute(
                "INSERT INTO publicacoes (texto) VALUES (%s)",
                (pub,)
            )

    conn.commit()
    cursor.close()
    conn.close()
    print(f"{len(publicacoes)} publicações inseridas com sucesso!")

# Executar a função
if __name__ == "__main__":
    inserir_publicacoes('/app/pubs.txt')

