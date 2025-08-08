# Scripts de ingestão

#### Dados de Produção

```python
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

BATCH_SIZE = 10000  # ajuste conforme memória e desempenho

def inserir_producao(caminho_arquivo):
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

    for linha in tqdm(linhas, desc="🔄 Inserindo produções", unit="linha"):
        partes = linha.strip().split("##")

        if len(partes) != 4:
            ignoradas += 1
            continue

        producaoID, titulo, ano_producao, tipo_ID = partes

        try:
            producaoID = int(producaoID)
            ano_producao = int(ano_producao) if ano_producao.lower() != 'null' else None
            tipo_ID = int(tipo_ID) if tipo_ID.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue

        registros.append((producaoID, titulo, ano_producao, tipo_ID))

        if len(registros) >= BATCH_SIZE:
            try:
                execute_values(cursor, """
                    INSERT INTO raw_data.producao (producaoID, titulo, ano_producao, tipo_ID)
                    VALUES %s
                    ON CONFLICT (producaoID) DO NOTHING
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
                INSERT INTO raw_data.producao (producaoID, titulo, ano_producao, tipo_ID)
                VALUES %s
                ON CONFLICT (producaoID) DO NOTHING
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
    inserir_producao('producao.txt')

```

#### Dados de Pessoa

```python
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

BATCH_SIZE = 10000  # ajuste conforme necessidade

def inserir_dados_equipe(caminho_arquivo):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Conexão com o banco estabelecida com sucesso.\n")
    except Exception as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}\n")
        return

    # Buscar todos producaoID válidos no banco
    try:
        cursor.execute("SELECT producaoID FROM raw_data.producao")
        producoes_validas = set(row[0] for row in cursor.fetchall())
        print(f"ℹ️ Encontrados {len(producoes_validas)} producaoID válidos no banco.")
    except Exception as e:
        print(f"❌ Erro ao buscar producaoID válidos: {e}")
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

        pessoaID, producaoID, papel = partes

        # Normalizar valores 'null'
        pessoaID = pessoaID if pessoaID.lower() != 'null' else None
        producaoID_val = None
        try:
            producaoID_val = int(producaoID) if producaoID.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue
        papel = papel if papel.lower() != 'null' else None

        # Validar se producaoID existe na tabela producao
        if producaoID_val not in producoes_validas:
            ignoradas += 1
            continue

        registros.append((pessoaID, producaoID_val, papel))

        if len(registros) >= BATCH_SIZE:
            try:
                execute_values(cursor, """
                    INSERT INTO raw_data.equipe (pessoaID, producaoID, papel)
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

    # Inserir registros restantes
    if registros:
        try:
            execute_values(cursor, """
                INSERT INTO raw_data.equipe (pessoaID, producaoID, papel)
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
    print(f"\n✅ Inserção finalizada. {inseridas} registros inseridos. {ignoradas} linhas ignoradas.")

if __name__ == "__main__":
    inserir_dados_equipe('equipe.txt')

```

#### Dados de Equipe

```python
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

BATCH_SIZE = 10000  # ajuste conforme o seu ambiente

def inserir_dados_equipe(caminho_arquivo):
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

        pessoaID, producaoID, papel = partes

        # Conversão e tratamento de valores null
        try:
            pessoaID_val = int(pessoaID) if pessoaID.lower() != 'null' else None
            producaoID_val = int(producaoID) if producaoID.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue

        papel_val = papel if papel.lower() != 'null' else None

        registros.append((pessoaID_val, producaoID_val, papel_val))

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
    print(f"\n✅ Inserção finalizada. {inseridas} registros inseridos. {ignoradas} linhas ignoradas.")

if __name__ == "__main__":
    inserir_dados_equipe('equipe.txt')

```

## Verificações de qualidade dos dados

```python
# [...]

try:
            pessoaID_val = int(pessoaID) if pessoaID.lower() != 'null' else None
            producaoID_val = int(producaoID) if producaoID.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue

        papel_val = papel if papel.lower() != 'null' else None

        registros.append((pessoaID_val, producaoID_val, papel_val))


# [...]
```

## Procedimentos de tratamento de erros

```python
# [...]

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
# [...]

# [...]
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
# [...]
```