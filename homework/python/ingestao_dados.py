import os
import re
import sys
import psycopg2
from tqdm import tqdm

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def inserir_dados():

    if len(sys.argv) != 5:
        print("Usage: python load_staging.py <path_to_data.txt> <table_name> '(column1,column2, ...)' 'tipo1,tipo2, ...'")
        sys.exit(1)

    ## Argumentos de entrada
    txt_path = sys.argv[1]
    table_name = sys.argv[2]
    columns_name = sys.argv[3]
    tipos = sys.argv[4].split(',')


    try:

        ## Conexão com o banco de dados
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()

        ## Definindo o esquema
        esquema = "raw_data"
        cursor.execute(f"SET search_path TO {esquema};")
        print(f"Esquema definido para: {esquema}")

        # Contar o número total de linhas
        with open(txt_path, "r", encoding="ISO-8859-1") as arquivo:
            total_linhas = sum(1 for _ in arquivo)

        ## Leitura do arquivo e inserção dos dados
        with open(txt_path, 'r', encoding='ISO-8859-1') as file:
            
            for line in tqdm(file, total=total_linhas, desc="Processando dados..."):

                try:    

                    valores_string = line.split('##')
                    valores = []
                    for i, valor in enumerate(valores_string):

                        if tipos[i] == 'string':
                            valor = re.sub(r"'", "''", valor.strip())
                            valores.append(f"\'{valor}\'")
                            
                        elif tipos[i] == 'int':

                            # Garantir que seja apenas numeros
                            numero = "".join(re.findall(r'\d+', valor.strip()))
                            valores.append(numero)

                    ## Inserir dados na tabela e descartar se ocorrer duplicatas
                    cursor.execute(
                        f"INSERT INTO {table_name} {columns_name} VALUES ({','.join(valores)}) ON CONFLICT DO NOTHING"
                    )
                except ValueError as e:
                    print(f"Erro ao processar a linha: '{line.strip()}'. Erro: {e}")
                    continue
        

        conn.commit()

    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Erro ao conectar ou inserir dados: {error}")

    finally:    
        cursor.close()
        conn.close()
    
    print("Dados inseridas com sucesso!")

if __name__ == "__main__":
    inserir_dados()