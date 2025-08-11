# Trabalho final DBA

## 📥 Script de Inserção de Dados no PostgreSQL com Log de Erros

Este script Python realiza a leitura de arquivos `.txt`, extrai os dados separados por `##`, e insere as informações em tabelas específicas de um banco de dados PostgreSQL. Ele também registra erros em arquivos de log separados e exibe o progresso via `tqdm`.

---

### ✅ Pré-requisitos

- Docker
- Docker compose

---

### ⚙️ Como executar

#### 1. Preparar os arquivos de entrada
Coloque os arquivos `equipe.txt`, `pessoa.txt` e `producao.txt` dentro da pasta:
```
apps/trabalho_final/
```

---

#### 2. Subir o ambiente Docker
```bash
docker compose up -d
```

---

#### 3. Criar o banco de dados
No **pgAdmin** ou via **psql**:
```sql
CREATE DATABASE cinetech_productions;
```

---

#### 4. Criar schemas e tabelas
Dentro do banco `cinetech_productions`:
1. Rode o script `sql/01_criacao_banco.sql` para criar os schemas (`raw_data`, `analytics`).
2. Rode o script `sql/02_projeto_esquema_raw_data.sql` para criar as tabelas do **raw_data**.

---

#### 5. Inserir dados no `raw_data`
1. Entre no container:
```bash
docker compose run trabalho-final bash
```
2. Execute o script de ingestão (detalhado no tópico *Execução Principal*):
```bash
python3 python/ingestao_dados.py
```

---

#### 6. Criar e popular o `analytics`
1. Rode o script `sql/02_projeto_esquema_analytics.sql` para criar as tabelas do **analytics**.
2. Popule as tabelas do analytics com o **seed** que está em `sql/02_projeto_esquema_analytics_seeds.sql mesmo script.

---

#### 7. Criar roles e permissões
```
sql/03_gerenciamento_usuarios.sql
```

---

#### 8. Criar views
```
sql/04_views_analytics.sql
```

---

#### 9. Executar consultas analíticas
```
sql/05_consultas_analise.sql
```

---

### 🚀 Execução Principal

O bloco `if __name__ == "__main__"` executa três chamadas à função `inserir_dados`:

```python
inserir_dados('/app/pessoa.txt', ...)
inserir_dados('/app/producao.txt', ...)
inserir_dados('/app/equipe.txt', ...)
```

Cada uma processa um arquivo específico e insere os dados na respectiva tabela do schema `raw_data`.

---

### 🧠 Função Principal

#### `inserir_dados(arquivo, sql_insert, colunas_minimas, montar_valores, verify=None)`

| Parâmetro         | Tipo       | Descrição |
|-------------------|------------|-----------|
| `arquivo`         | `str`      | Caminho absoluto do arquivo `.txt` a ser processado |
| `sql_insert`      | `str`      | Query de inserção parametrizada (`%s`) |
| `colunas_minimas` | `int`      | Quantidade mínima de colunas exigidas para considerar a linha válida |
| `montar_valores`  | `lambda`   | Função que transforma a lista de dados em uma tupla para o insert |
| `verify`          | `callable` | *(opcional)* Função de verificação que recebe `(cursor, dados)` e retorna `True` ou `False`. Se retornar `False`, a linha será ignorada |

---

### ✂️ Função de limpeza de dados

#### `limpar_numerico(valor)`

Remove todos os caracteres não numéricos de uma string. Retorna `None` se a string for `"null"`, vazia ou inválida.

```python
limpar_numerico("123-45")   # 12345
limpar_numerico("null")     # None
```

---

### 📁 Estrutura de Arquivo Esperada

Cada linha do `.txt` deve conter os campos separados por `##`, como:

```
123##Nome da Pessoa
456##Título da Produção##2002##1
789##123##Ator Principal
```

---

### 💡 Exemplo com verificação de chaves estrangeiras

No caso do arquivo `equipe.txt`, apenas devem ser inseridas linhas se os IDs de pessoa e produção existirem:

```python
def verificar_pessoa_e_producao(cursor, dados):
    pessoa_id = limpar_numerico(dados[0])
    producao_id = limpar_numerico(dados[1])

    cursor.execute("SELECT 1 FROM raw_data.pessoas WHERE pessoa_id = %s", (pessoa_id,))
    if not cursor.fetchone():
        return False

    cursor.execute("SELECT 1 FROM raw_data.producoes WHERE producao_id = %s", (producao_id,))
    return cursor.fetchone() is not None
```

Uso:

```python
inserir_dados(
    '/app/equipe.txt',
    """
    INSERT INTO raw_data.equipes (pessoa_id, producao_id, papel)
    VALUES (%s, %s, %s)
    ON CONFLICT (pessoa_id, producao_id) DO NOTHING
    """,
    colunas_minimas=3,
    montar_valores=lambda d: (
        limpar_numerico(d[0]),
        limpar_numerico(d[1]),
        d[2]
    ),
    verify=verificar_pessoa_e_producao
)
```

---

### 🧾 Logs de Erro

- Todos os erros são registrados em um arquivo no mesmo diretório do `.txt`.
- Nome: `arquivo_erro.txt` (ex: `producao_erro.txt`)
- Tipos de erro:
  - Linhas com colunas insuficientes
  - Verificações que falham (`verify`)
  - Erros de conversão ou SQL

---

### 🔄 Exemplo de Log de Erro

```txt
[L438788] erro: 447145##Traversées 11###2004##1 → invalid input syntax for type integer: "#2004"
[L438789] erro: 480311##While She Powdered Her Nose##1912##1 → current transaction is aborted, commands ignored until end of transaction block
[L245123] verificação falhou: 999##888##Roteirista
```

---

### ✅ Resultado Final

- Exibe o total de linhas processadas vs. totais.
- Mostra caminho do log de erros.
- Exibe uma barra de progresso `tqdm` durante o processo.

---
