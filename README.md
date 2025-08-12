# CineTech Studios - Projeto de Banco de Dados (Trabalho Final DBA)

Este repositório contém a implementação completa do projeto prático de Administração de Banco de Dados (DBA), no qual gerenciamos os dados da empresa fictícia CineTech Studios.

---

## Estrutura do Projeto

```bash
homework/
├── sql/
│   ├── 01_criacao_banco.sql
│   ├── 02_projeto_esquema.sql
│   ├── 03_ingestao_dados.sql (feito em Python e SQL para teste)
│   ├── 04_gerenciamento_usuarios.sql
│   ├── 05_views_analytics.sql
│   ├── 06_consultas_analise.sql
│   ├── 07_bonus_validador_de_dados.sql
│   ├── 08_bonus_testes_automatizados.sql
│   ├── 09_bonus_dashboard de monitoramento.sql
│   └── 10_bonus_arquivamento de dados.sql
├── python/
│   └── ingestao_dados.py
├── docs/
│   ├── analise_performance.md
│   ├── documentacao_esquema.md
│   ├── guia_acesso_usuarios.md
│   ├── guia_backup_recuperacao.md
│   └── guia_bonus_.md  
└── README.md
```
## DER
<img width="1068" height="273" alt="DER" src="https://github.com/user-attachments/assets/53b647dd-e3d1-4088-8852-8b7c5edb72c1" />

---

# Guia rápido — Como rodar o projeto

> Requisitos: Git, Docker, Python 3.11 instalados.

## 1) Clonar o repositório
```bash
git clone <URL_DO_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>
```

## 2) Subir os serviços
```bash
docker compose up -d
```

## 3) Acessar o PostgreSQL (psql no container)
> Acesso direto ao **PostgreSQL** via `psql` dentro do container.

```bash
docker exec -it postgresql bash
psql -U postgres
```

Criar o banco (e listar para conferir):
```sql
CREATE DATABASE cinetech_productions;
\l  -- opcional: lista os bancos
```

Apagar o banco (se precisar):
```sql
DROP DATABASE cinetech_productions;
```

## 4) Inserir dados
Execute a rotina de ingestão no container `ingestao`:

```bash
docker exec -it ingestao bash

cd /app
ls

python ingestao_dados.py
```

> O script `ingestao_dados.py` insere os dados no banco de dados. Ao terminar, você pode fazer consultas no **pgAdmin** (se houver serviço no compose) ou diretamente via `psql`.

## 5) Comandos Docker úteis (recriar serviços)
Caso precise recriar os containers/volumes:

```bash
docker compose down --volumes --remove-orphans
docker compose build
docker compose up -d
```

---
## Mapeamento dos IDs da tabela

```bash
| tipo_id | Categoria         | Justificativa (exemplos de títulos) |
|---------|-------------------|--------------------------------------|
| 1       | Filmes            | “Campanile d’oro”, “Cultural Menace”, “Clinic, The”, “Black Spot, The” |
| 2       | Séries de TV      | “Star Trek: Deep Space Nine”, “Adventure Inc.”, “Calle en que vivimos, La” |
| 3       | Documentários     | “Überfall in Glasgow”, “Überstunde”, “Über ganz Spanien wolkenloser Himmel” |
| 4       | Curtas-metragens  | “Sports Illustrated Swimsuit”, “Paris Chic”, “Talk Dirty to Me, Part III” |
| 5       | Clipes de Música  | “Zodiak”, “XV FIFA World Cup”, “Zeiten ändern sich”, “Winning Streak, The” |
| 6       | Videogames        | “Cold Fear”, “Counter Strike”, “Before Crisis: Final Fantasy VII”, “Cruis’n Exotica” |
| 7       | Animações         | “Jobs for the Girls”, “The Box of Chocolates”, “Act 8” (sugere animações curtas) |
```

## Esquema do Banco de Dados

- Dois schemas foram criados:
  - `raw_data`: estrutura bruta com dados de produções, pessoas e equipes.
  - `analytics`: estrutura segmentada por tipo de produção para facilitar análise.

- Tabelas criadas com tipos apropriados, chaves primárias e estrangeiras.

- Views analíticas para sumarização e insights:
  - `production_summary`
  - `top_actors_by_type`
  - `yearly_production_trends`
  - `crew_analysis`

- Índices criados nas colunas `ano`, `tipo_id`, `id_pessoa`, `id_producao`, e `LOWER(papel)` para otimizar joins e filtros.

---

## Acesso de Usuários

- 6 usuários criados com níveis distintos de acesso:
  - `analyst_movies`, `analyst_tv`, `analyst_games`, `analyst_docs`: acesso somente leitura por tipo.
  - `analyst_all`: leitura total no schema `analytics`.
  - `data_scientist`: leitura e escrita no schema `analytics`.

- Permissões concedidas com `GRANT`/`REVOKE` e testadas com `SET ROLE`.

---

## Ingestão de Dados

- Script de ingestão implementado em `python/ingestao_dados.py`:
  - Lê arquivos `.parquet`
  - Trata dados ausentes e duplicados
  - Valida chaves estrangeiras antes de inserir
  - Usa `to_sql(..., method="multi")` e `tqdm` para performance e feedback visual

- Schema `raw_data` é populado com:
  - `producao.parquet`
  - `pessoa.parquet`
  - `equipe.parquet`

---

## Desempenho

- `EXPLAIN ANALYZE` utilizado para validar performance das consultas analíticas
- PostgreSQL aplicou paralelismo (`Parallel Seq Scan`, `HashAggregate`, etc.)
- Nenhum gargalo detectado
- Particionamento avaliado, mas considerado desnecessário neste momento
- Índices mantidos para garantir desempenho em análises temporais e relacionais

---

## Backup e Recuperação

## Gerar Backup Dentro do Container

Acesse o container e gere o arquivo `.dump` com o comando `pg_dump`:

```bash
docker exec -it postgresql bash -c "pg_dump -U postgres -F c -b -v -f /tmp/backup_cinetech.dump cinetech_productions"
```

Verifique se o arquivo foi criado e possui tamanho maior que zero:

```bash
docker exec -it postgresql ls -lh /tmp/backup_cinetech.dump
```

---

## Criar Banco de Teste e Restaurar

Primeiro, garanta que o banco de teste não exista e crie-o novamente:

```bash
docker exec -it postgresql dropdb -U postgres --if-exists cinetech_restore_test
docker exec -it postgresql createdb -U postgres cinetech_restore_test
```

Em seguida, restaure o backup para o banco de teste:

```bash
docker exec -it postgresql pg_restore -U postgres -d cinetech_restore_test --clean --if-exists -v /tmp/backup_cinetech.dump
```
---
Mais detalhes em:
- (https://github.com/RafaelQuirino/dba_postgresql/blob/homework/Willgnner-Santos/homework/docs/guia_backup_recuperacao.md)

## Status

Todas as fases do projeto foram executadas:
- Criação de banco e esquemas
- Ingestão massiva de dados
- Controle de acesso seguro
- Criação de views analíticas
- Análises de negócio e otimização
- Backup e documentação abrangente

---

## Bônus e boas práticas aplicadas

- Indexação estratégica
- Estrutura modular do projeto
- Scripts SQL organizados por etapa
- Documentação completa em Markdown para entrega e reuso

---

## Conversão de Arquivos TXT para Parquet

Antes da ingestão no banco de dados, os arquivos originais `equipe.txt`, `pessoa.txt` e `producao.txt` foram convertidos para o formato `.parquet`, garantindo melhor desempenho e compatibilidade com a leitura em batch via pandas.

O script de conversão executou os seguintes passos:

1. Leitura dos arquivos `.txt` com separador `##` e codificação `cp1252`.
2. Renomeação das colunas com nomes apropriados.
3. Tratamento de erros de leitura com fallback de caracteres inválidos.
4. Conversão para `.parquet` usando `fastparquet`, com indexação desativada.
5. Criação de uma versão filtrada de `producao.parquet`, removendo anos inválidos (ano = 0).

Além disso, foi realizada uma análise exploratória dos arquivos convertidos com verificação de:
- Tipos de dados
- Quantidade de registros
- Presença de valores nulos
- Colunas duplicadas
- Estatísticas descritivas básicas

---

## Uso de Variáveis de Ambiente (.env)

O projeto utiliza um arquivo `.env` para armazenar credenciais e configurações sensíveis de acesso ao banco de dados. Isso garante segurança e facilita a configuração do ambiente.

Exemplo de variáveis utilizadas:
```
DB_HOST=postgresql
DB_PORT=5432
DB_NAME=cinetech_productions
DB_USER=postgres
DB_PASSWORD=postgres123
```

As variáveis foram carregadas no script Python usando `os.getenv` para montar a `engine_url` de conexão com o PostgreSQL via SQLAlchemy.
