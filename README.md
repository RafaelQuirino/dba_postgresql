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

## Instruções - Como Executar o Projeto?

Requisitos: Docker, Git e Python 3.9.13 instalados.

### Passo 1: Clonar o Reposiório 

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

Execute a rotina de ingestão no container ```ingestao```:

```bash
docker exec -it ingestao bash

cd /app
ls

python ingestao_dados.py
```
O script ```ingestao_dados.py``` carrega as informações no banco. Depois disso, você pode consultar os dados pelo pgAdmin (caso o serviço estiver no compose) ou diretamente pelo ```psql```.

**OBS.:** Para acessar o pgAdmin basta inserir ```localhost:8080``` (geralmente) no seu navegador, caso na seja essa a porta, verificar no arquivo ```docker-compose.yml```.

## Comandos Docker Úteis:

Caso deseje recriar os containers/volumes:
```bash
docker compose down --volumes --remove-orphans
docker compose build
docker compose up -d
```
## Esquema do Banco de Dados:

- Foram criados dois schemas:

    - ```raw_data```: estrutura bruta com dados de produções, pessoas e equipes.
    - ```analytics```: estrutura segmentada por tipo de produção para facilitar análise.

- Tabelas criadas com tipos apropriados, chaves primárias e estrangeiras.

- Views analíticas para sumarização e insights:

    - ```production_summary```
    - ```top_actors_by_type```
    - ```yearly_production_trends```
    - ```crew_analysis```

- Índices criados nas colunas ano_producao, tipo_id, pessoaID, producaoID, e LOWER(papel) para otimizar joins e filtros.

## Mapeamento do Esquema Analítico:

| tipo_id | Categoria        | Justificativa (exemplos de títulos)                                                                                      |
|--------:|------------------|--------------------------------------------------------------------------------------------------------------------------|
| 1       | Filmes           | “Campanile d’oro”, “Cultural Menace”, “Clinic, The”, “Black Spot, The”                                                   |
| 2       | Séries de TV     | “Star Trek: Deep Space Nine”, “Adventure Inc.”, “Calle en que vivimos, La”                                              |
| 3       | Curtas-metragens   | “Überfall in Glasgow”, “Überstunde”, “Über ganz Spanien wolkenloser Himmel”                                             |
| 4       | Filmes independentes | “Sports Illustrated Swimsuit”, “Paris Chic”, “Talk Dirty to Me, Part III”                                               |
| 5       | Documentários | “Zodiak”, “XV FIFA World Cup”, “Zeiten ändern sich”, “Winning Streak, The”                                              |
| 6       | Videogames       | “Cold Fear”, “Counter Strike”, “Before Crisis: Final Fantasy VII”, “Cruis’n Exotica”                                     |
| 7       | Episódios        | “Jobs for the Girls”, “The Box of Chocolates”, “Act 8” (sugere animações curtas)                                        |

## Acesso de Usuários:

- Foram criados 6 usuários com níveis de acesso distintos:

    - ```analyst_movies```, ```analyst_tv```, ```analyst_games```, ```analyst_docs```: acesso somente leitura por tipo.
    - ```analyst_all```: leitura total no schema analytics.
    - ```data_scientist```: leitura e escrita no schema analytics.

- Permissões concedidas com ```GRANT/REVOKE``` e testadas com ```SET ROLE```.

## Ingestão de Dados:

## Uso de Variáveis de Ambiente (.env):

O projeto utiliza um arquivo ```.env``` para armazenar credenciais e configurações sensíveis de acesso ao banco de dados. Isso garante segurança e facilita a configuração do ambiente.

Exemplo de variáveis utilizadas:
