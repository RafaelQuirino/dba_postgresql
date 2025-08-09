# 🎬 Trabalho Prático — Banco de Dados de Produções Artísticas

> Solução do **Trabalho Final** da disciplina de **Administração de Bancos de Dados (DBA)**, dedicada ao gerenciamento dos dados da empresa fictícia **CineTech Studios**.

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Python-3.9-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)

---

## 🗂️ Estrutura do Projeto
<details>
<summary><b>Mostrar/ocultar árvore de diretórios</b></summary>

```text
homework/
├── sql/
│   ├── 01_criacao_banco.sql
│   ├── 02_projeto_esquema.sql
│   ├── 03_gerenciamento_usuarios.sql
│   ├── 04_views_analytics.sql
│   ├── 05_consultas_analise.sql
├── python/
│   └── ingestao_dados.py
├── docs/
│   ├── documentacao_esquema.md
│   ├── guia_acesso_usuarios.md
└── README.md
```
<details>

## ⚙️ Requisitos
🐳 **Docker** e **Docker Compose**
🐍 **Python 3.9.13**
🧰 **Git**

## 🚀 Como Executar
### 1) 📥 Clonar o repositório

```bash
git clone <url_do_repositorio>
cd <pasta_do_repositorio_clonado>
```

### 2) 🧱 Subir os serviços com Docker Compose
```bash
docker compose up -d
```

### 3) 🐘 Acessar o PostgreSQL via psql
```bash
docker exec -it postgresql bash
psql -U postgres
```
### 4) 📦 Inserir dados (ingestão)
Execute a rotina de ingestão no container ```ingestao```:

```bash
docker exec -it ingestao bash

cd /app
ls

python ingestao_dados.py
```
💡 **Dica:** Após a ingestão, consulte os dados pelo **pgAdmin** (se estiver no compose) ou diretamente pelo **psql**.
🔎 **pgAdmin:** acesse ```http://localhost:8080``` (ou a porta definida no ```docker-compose.yml```).

## 🧰 Comandos Docker Úteis
Recriar containers/volumes do zero:
```bash
docker compose down --volumes --remove-orphans
docker compose build
docker compose up -d
```

## 🧱 Esquema do Banco de Dados
- 🗃️ **Schemas:**

    - ```raw_data```: dados brutos (produções, pessoas e equipes).

    - ```analytics```: estrutura segmentada por tipo de produção para facilitar análises.

- 🔑 **Integridade:**

    - Tabelas com tipos apropriados, chaves primárias e estrangeiras.

- 👁️ **Views analíticas:**

    - ```production_summary```

    - ```top_actors_by_type```

    - ```yearly_production_trends```

    - ```crew_analysis```

- 🚀 **Performance:**

    - Índices em: ```ano_producao```, ```tipo_id```, ```pessoaID```, ```producaoID```, e ```LOWER(papel)``` para otimizar ***joins*** e filtros.

## 📊 Mapeamento do Esquema Analítico
| tipo\_id | Categoria               | Justificativa (exemplos de títulos)                                                  |
| -------: | ----------------------- | ------------------------------------------------------------------------------------ |
|        1 | 🎥 Filmes               | “Campanile d’oro”, “Cultural Menace”, “Clinic, The”, “Black Spot, The”               |
|        2 | 📺 Séries de TV         | “Star Trek: Deep Space Nine”, “Adventure Inc.”, “Calle en que vivimos, La”           |
|        3 | 🎞️ Curtas-metragens    | “Überfall in Glasgow”, “Überstunde”, “Über ganz Spanien wolkenloser Himmel”          |
|        4 | 🎬 Filmes independentes | “Sports Illustrated Swimsuit”, “Paris Chic”, “Talk Dirty to Me, Part III”            |
|        5 | 🎙️ Documentários       | “Zodiak”, “XV FIFA World Cup”, “Zeiten ändern sich”, “Winning Streak, The”           |
|        6 | 🕹️ Videogames          | “Cold Fear”, “Counter Strike”, “Before Crisis: Final Fantasy VII”, “Cruis’n Exotica” |
|        7 | 📼 Episódios            | “Jobs for the Girls”, “The Box of Chocolates”, “Act 8” (sugere animações curtas)     |

## 👤 Acesso de Usuários
- 👥 **Usuários e perfis:**

    - ```analyst_movies```, ```analyst_tv```, ```analyst_games```, ```analyst_docs```: leitura por tipo.

    - ```analyst_all```: leitura completa no schema analytics.

    - ```data_scientist```: leitura e escrita no schema analytics.

- 🛡️ **Permissões:**

    - Concedidas com ```GRANT/REVOKE``` e testadas com ```SET ROLE```.

## 🧩 Script de Ingestão (```python/ingestao_dados.py```)

- 🔐 Carrega variáveis do ```.env``` para conexão ao ```PostgreSQL``` via ```psycopg2```.

- 📄 Lê ```.txt``` (delimitados por ```##```) em ```homework/data```, detectando ***encoding*** com ```chardet``` e ignorando linhas vazias.

- 🧽 Normaliza dados: ```to_int``` para inteiros; ```ano_para_db``` converte ```0``` em ```NULL``` (```None```).

- 🚚 Insere em lotes com ```execute_batch(..., page_size=1000)``` e usa ```ON CONFLICT DO NOTHING``` para evitar duplicatas.

- 🔄 Transação única (```autocommit=False```): ```commit``` ao final; ```rollback``` em caso de erro.

- ⏱️ Progresso com ```tqdm``` e descarte de linhas malformadas.

🗄️ **Tabelas de destino:**

- Producao(```producaoID```, ```titulo```, ```ano_producao```, ```tipo_ID```)

- Pessoa(```pessoaID```, ```nome```)

- Equipe(```pessoaID```, ```producaoID```, ```papel```)

📥 **Arquivos ingeridos:**

- ```homework/data/producao.txt```

- ```homework/data/pessoa.txt```

- ```homework/data/equipe.txt```

## 🔐 Variáveis de Ambiente (.env)
O projeto utiliza um arquivo ```.env``` para credenciais e parâmetros sensíveis.

```bash
DB_HOST=postgresql
DB_PORT=5432
DB_NAME=cinetech_productions
DB_USER=postgres
DB_PASSWORD=postgres123
```
