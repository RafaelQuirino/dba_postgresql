# Trabalho Prático: Banco de Dados de Produções Artísticas

Neste repositório encontra-se a solução do Trabalho Final da disciplina de Administração de Bancos de Dados (DBA), dedicada ao gerenciamento dos dados da empresa fictícia CineTech Studios.

## Estrutura do Projeto

```text
homework/
├── sql/
│   ├── 01_criacao_banco.sql
│   ├── 02_projeto_esquema.sql
│   ├── 03_gerenciamento_usuarios.sql
│   ├── 04_views_analytics.sql
│   ├── 05_consultas_analise.sql
├── python/
│   └── ingestao_dados.py
├── docs/
│   ├── documentacao_esquema.md
│   ├── guia_acesso_usuarios.md
└── README.md
```

## Instruções - Como executar o projeto?

Requisitos: Docker, Git e Python 3.9.13 instalados.

### Passo 1: Clonar o reposiório 

```bash
git clone <url_do_repositorio>
cd <pasta_do_repositorio_clonado>
```
### Passo 2: Subir o docker-compose

```bash
docker compose up -d
```
### Passo 3: Acessar o PostgreSQL via psql

```bash
docker exec -it postgresql bash
psql -U postgres
```

### Passo 4: Inserção de dados

