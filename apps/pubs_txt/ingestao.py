import psycopg2
import csv

# Conexão com o PostgreSQL
conn = psycopg2.connect(
    host="172.18.0.2",
    port="5432",
    dbname="cinetech_productions",
    user="postgres",
    password="postgres123"
)
cur = conn.cursor()

# Função para carregar arquivos
def importar_arquivo(nome_arquivo, tabela, colunas):
    with open(nome_arquivo, encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='|')
        next(reader)  # pular cabeçalho
        for linha in reader:
            cur.execute(
                f"INSERT INTO {tabela} ({','.join(colunas)}) VALUES ({','.join(['%s'] * len(colunas))})",
                linha
            )
    conn.commit()
    print(f"{nome_arquivo} importado com sucesso!")

# Importar producao
importar_arquivo("producao.txt", "raw_data.producao", ["producaoID", "titulo", "ano_producao", "tipo_ID"])

# Importar pessoa
importar_arquivo("pessoa.txt", "raw_data.pessoa", ["pessoaID", "nome"])

# Importar equipe
importar_arquivo("equipe.txt", "raw_data.equipe", ["pessoaID", "producaoID", "papel"])

# Finalizar
cur.close()
conn.close()
print("Todos os dados foram importados.")