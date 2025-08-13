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
    linhas_ignoradas = []  # Nova lista para armazenar as linhas ignoradas

    for linha in tqdm(linhas, desc="🔄 Inserindo produções", unit="linha"):
        partes = linha.strip().split("##")

        if len(partes) != 4:
            ignoradas += 1
            linhas_ignoradas.append(f"Formato inválido: {linha.strip()}")
            continue

        producaoID, titulo, ano_producao, tipo_ID = partes

        try:
            producaoID = int(producaoID)
            ano_producao = int(ano_producao) if ano_producao.lower() != 'null' else None
            tipo_ID = int(tipo_ID) if tipo_ID.lower() != 'null' else None
        except Exception as ex:
            ignoradas += 1
            linhas_ignoradas.append(f"Erro de conversão de tipo: {linha.strip()} (Detalhe: {ex})")
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
                # Adiciona as linhas do lote ignorado à lista
                for reg in registros:
                    linhas_ignoradas.append(f"Erro de inserção no banco: {reg}")
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
            for reg in registros:
                linhas_ignoradas.append(f"Erro de inserção no banco: {reg}")
            ignoradas += len(registros)

    cursor.close()
    conn.close()
    print(f"\n✅ Inserção concluída. {inseridas} inseridas, {ignoradas} ignoradas.")

    # Imprimir as linhas ignoradas, se houver
    if linhas_ignoradas:
        print("\n--- Linhas ignoradas ---")
        for linha in linhas_ignoradas:
            print(linha)
        print("------------------------")

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

# Conversão e tratamento de valores null
        try:
            pessoaID_val = int(pessoaID) if pessoaID.lower() != 'null' else None
            producaoID_val = int(producaoID) if producaoID.lower() != 'null' else None
        except Exception:
            ignoradas += 1
            continue

        papel_val = papel if papel.lower() != 'null' else None

# [...]
```

## Procedimentos de tratamento de erros

```python
# [...]
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