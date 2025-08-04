import os
import psycopg2
from tqdm import tqdm

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def inserir_dados(arquivo, sql_insert, colunas_minimas, montar_valores):
    print(f"\nLendo arquivo: {arquivo}")
    print(f"Conectando ao banco de dados {DB_CONFIG['database']}...")
    linhas_completas = 0
    erros_path = arquivo.replace(".txt", "_erro.txt")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    with open(arquivo, 'r', encoding='iso-8859-1') as f:
        linhas = f.readlines()

    with open(erros_path, 'w', encoding='utf-8') as log_erro:
        for i, linha in enumerate(tqdm(linhas, desc=f"Processando {os.path.basename(arquivo)}", unit="linha")):
            dados = linha.strip().split('##')
            if len(dados) < colunas_minimas:
                log_erro.write(f"Linha {i+1} ignorada (colunas insuficientes): {linha.strip()}\n")
                continue
            try:
                valores = montar_valores(dados)
                cursor.execute(sql_insert, valores)
                linhas_completas += 1
            except Exception as e:
                conn.rollback()
                log_erro.write(f"Linha {i+1} erro: {linha.strip()} - Erro: {str(e)}\n")
                continue

    conn.commit()
    cursor.execute("SELECT COUNT(*) FROM raw_data.pessoas")
    print("Linhas no banco após inserção:", cursor.fetchone()[0])
    cursor.execute("SELECT COUNT(*) FROM public.pessoas")
    print("Linhas em public.pessoas:", cursor.fetchone()[0])
    cursor.close()
    conn.close()

    print(f"{linhas_completas} linhas inseridas com sucesso de {len(linhas)}!")
    print(f"Erros registrados em: {erros_path}")

if __name__ == "__main__":
    inserir_dados(
        '/app/pessoa.txt',
        "INSERT INTO raw_data.pessoas (pessoa_id, nome) VALUES (%s, %s)",
        2,
        lambda dados: (dados[0], dados[1])
    )

    inserir_dados(
        '/app/producao.txt',
        "INSERT INTO raw_data.producoes (producao_id, titulo, ano, tipo_id) VALUES (%s, %s, %s, %s)",
        4,
        lambda dados: (dados[0], dados[1], dados[2], dados[3])
    )

    inserir_dados(
        '/app/equipe.txt',
        "INSERT INTO raw_data.equipes (pessoa_id, producao_id, papel) VALUES (%s, %s, %s)",
        3,
        lambda dados: (dados[0], dados[1], dados[2])
    )