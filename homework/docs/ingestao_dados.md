

# Documentação Ingestão de Dados

### 1. Scripts de ingestão

1. Ingestão Schema raw_data

```python
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


```

2. Ingestão Schema analytics

```sql
INSERT INTO analytics.movies (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 1;


INSERT INTO analytics.tv_shows (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 7;


INSERT INTO analytics.video_games (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 6;


INSERT INTO analytics.documentaries (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 4;


INSERT INTO analytics.short_films (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 3;


INSERT INTO analytics.music_videos (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 5;


INSERT INTO analytics.animations (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 2;

```



### 2. Verificações de qualidade dos dados

1. Tratando aspas simples dentro da string para inserção no SQL.
```python
        if tipos[i] == 'string':
            valor = re.sub(r"'", "''", valor.strip())
            valores.append(f"\'{valor}\'")

```

 2. Validando apenas números nas colunas definidas como inteiro.
```python
        elif tipos[i] == 'int':

            # Garantir que seja apenas numeros
            numero = "".join(re.findall(r'\d+', valor.strip()))
            valores.append(numero)
```

 3. Garantir a insersão de chaves unicas.
```python
    cursor.execute(
        f"INSERT INTO {table_name} {columns_name} VALUES ({','.join(valores)}) ON CONFLICT DO NOTHING"
    )
```

### 3. Procedimentos de tratamento de erros

 1. Tratamento de erros na leitura de cada linha dos arquivo.
```python

    try:

    ## .....

    except ValueError as e:
        print(f"Erro ao processar a linha: '{line.strip()}'. Erro: {e}")
        continue
```

 2. Tratamento de erros na conexão com o BD.
```python

    try:

    ## .....

    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Erro ao conectar ou inserir dados: {error}")
```

