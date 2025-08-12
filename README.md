# CineTech Studios - Projeto de Banco de Dados (Trabalho Final DBA)

Este repositório contém a implementação completa do projeto prático de Administração de Banco de Dados (DBA) para a empresa fictícia CineTech Studios. O projeto abrange desde a configuração do ambiente e a modelagem do banco de dados até a ingestão massiva de dados, gerenciamento de segurança e análises.

-----

## Estrutura do Projeto

A estrutura final do nosso projeto ficou organizada da seguinte forma:

```bash
.
├── data/
│   ├── equipe.txt
│   ├── pessoa.txt
│   └── producao.txt
├── python/
│   ├── ingestao_dados.py
│   └── requirements.txt
├── sql/
│   ├── 01_criacao_banco.sql
│   ├── 02_projeto_esquema.sql
│   ├── 03_ingestao_dados.sql (feito em Python apenas)
│   ├── 04_gerenciamento_usuarios.sql
│   ├── 05_views_analytics.sql
│   ├── 06_consultas_analise.sql
│   ├── 07_bonus_validador_de_dados.sql
│   ├── 08_bonus_testes_automatizados.sql
│   ├── 09_bonus_dashboard de monitoramento.sql
│   └── 10_bonus_arquivamento de dados.sql
├── docs/
│   ├── ...(documentação complementar)
├── docker-compose.yml
├── python.Dockerfile
└── README.md
```

-----

## Guia Rápido — Como Rodar o Projeto

> **Requisitos:** Git e Docker (com Docker Compose V2) instalados.

### 1\. Clonar o Repositório

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>
```

### 2\. Iniciar o Ambiente e Ingerir os Dados

O projeto foi configurado para ser executado com um único comando. O script de ingestão é chamado automaticamente após o ambiente Docker estar pronto e saudável.

**Subir os serviços (Postgres, App, PgAdmin):**

```bash
docker compose up -d --build
```

**Executar o processo de ingestão e ETL:**
O script Python irá criar os schemas, as tabelas, carregar os dados para uma área de *staging*, limpá-los e transferi-los para as tabelas finais em `raw_data`.

```bash
docker compose exec app python ingestao_dados.py
```

### 3\. Acessar os Serviços

  * **PostgreSQL (via psql):**
    ```bash
    docker compose exec postgres psql -U postgres -d cinetech_productions
    ```
  * **pgAdmin:**
    Acesse `http://localhost:8080` no seu navegador com as credenciais definidas no `docker-compose.yml`.

### 4\. Comandos Docker Úteis

Para parar, recriar ou limpar o ambiente:

```bash
# Parar todos os serviços
docker compose down

# Parar serviços e remover volumes de dados (reset completo)
docker compose down --volumes --remove-orphans
```

-----

## Mapeamento dos Tipos de Produção (`tipo_ID`)

Após uma análise exploratória dos dados, o seguinte mapeamento foi deduzido:

| tipo\_ID | Categoria Deduzida | Justificativa (Baseado em Contagem e Amostra de Títulos) |
|:---|:---|:---|
| **1** | Filme (Movie) | Categoria mais numerosa, com títulos de obras únicas. |
| **2** | Série de TV (TV Show) | Títulos de séries completas (e.g., "Primer amor"). |
| **7** | Episódio de TV (TV Episode) | A mais numerosa após filmes, com títulos no formato `(#5.26)` ou `(YYYY-MM-DD)`. |
| **3** | Documentário / Telefilme | Títulos variados que se encaixam em produções feitas para TV. |
| **4** | Vídeo (Video Release) | Títulos que sugerem lançamentos diretos para vídeo/DVD. |
| **6** | Videogame | Categoria de nicho, mapeada para videogames. |
| **5** | Outros Tipos | Categoria menos numerosa, provavelmente curtas ou clipes. |

-----

## Esquema do Banco de Dados

  * **Três schemas** foram utilizados para uma organização clara do fluxo de dados:

      * `staging`: Área de trabalho temporária para ingestão dos dados brutos como texto, evitando falhas.
      * `raw_data`: Contém as tabelas finais `producao`, `pessoa` e `equipe` com tipos de dados corretos, chaves e constraints de qualidade.
      * `analytics`: Schema final com tabelas especializadas (`movies`, `tv_shows`, etc.) e views para facilitar a análise de negócio.

  * **Views Analíticas** foram criadas para simplificar consultas, como a `analytics.production_summary`.

  * **Índices estratégicos** foram criados nas chaves estrangeiras e colunas frequentemente usadas em filtros (`ano_producao`, `tipo_id`) para otimizar o desempenho das consultas.

-----

## Gerenciamento de Acesso

  * **6 roles (usuários)** foram criados com senhas e permissões específicas, seguindo o Princípio do Menor Privilégio.
      * `analyst_movies`, `analyst_tv`, `analyst_docs`, `analyst_games`: Acesso de leitura (`SELECT`) apenas às suas respectivas tabelas no schema `analytics`.
      * `analyst_all`: Acesso de leitura (`SELECT`) a **todas** as tabelas do schema `analytics`.
      * `data_scientist`: Permissões totais (`ALL PRIVILEGES`) para ler, escrever e modificar dados e objetos no schema `analytics`.
  * As permissões foram concedidas usando `GRANT` e validadas através de consultas ao `information_schema`.

-----

## Processo de Ingestão de Dados (ETL)

A ingestão foi implementada no script `python/ingestao_dados.py` e seguiu um robusto processo de ETL:

1.  **Extração (Extract):** Leitura dos arquivos `.txt` (com encoding `cp1252`) em memória, usando Python.
2.  **Transformação (Transform):**
      * O delimitador `##` de múltiplos caracteres foi substituído em tempo real por um caractere de controle seguro (`\x1f`), resolvendo a limitação do comando `COPY`.
      * Dados inválidos (e.g., anos de produção com caracteres não numéricos ou valores fora do range aceitável) foram limpos e/ou filtrados durante a carga para a camada final.
3.  **Carga (Load):**
      * **Carga para Staging:** Os dados transformados foram carregados via `psycopg2.copy_expert` para tabelas no schema `staging`.
      * **Carga para Raw Data:** Um segundo passo, via SQL, moveu os dados de `staging` para `raw_data`, aplicando as conversões de tipo, validações de `CHECK` e garantindo a integridade referencial com as chaves estrangeiras.

-----

## Backup e Recuperação

Procedimentos de backup e recuperação foram definidos e testados.

**1. Gerar Backup (Dump)**
O comando abaixo, executado no host, gera um backup completo do banco no formato customizado do PostgreSQL.

```bash
docker compose exec postgres pg_dump -U postgres -F c -b -v -f /tmp/backup_cinetech.dump cinetech_productions
```

**2. Restaurar Backup**
Para restaurar, primeiro criamos um banco de dados de teste e em seguida aplicamos o backup.

```bash
# Criar um banco de destino limpo
docker compose exec postgres createdb -U postgres cinetech_restore_test

# Restaurar o backup
docker compose exec postgres pg_restore -U postgres -d cinetech_restore_test --clean /tmp/backup_cinetech.dump
```

-----

## Conclusão

O projeto foi concluído com sucesso, cobrindo todas as fases essenciais de administração de um banco de dados em um cenário prático. As dificuldades encontradas no caminho, especialmente relacionadas à configuração do ambiente e à qualidade dos dados, foram cruciais para o aprendizado e para a implementação de uma solução final robusta e resiliente.