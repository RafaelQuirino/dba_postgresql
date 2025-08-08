
# 🎬 CineTech Studios - Projeto de Banco de Dados com PostgreSQL

Bem-vindo ao repositório do projeto prático de administração de banco de dados (DBA) da **CineTech Studios**, uma empresa fictícia de entretenimento. Este projeto foi desenvolvido como parte do curso de DBA e inclui **todo o ciclo de vida de um banco de dados PostgreSQL**, desde a ingestão de dados até controle de acesso e análises.

---

## ✅ 1. Visão Geral

Neste projeto você encontrará:

- 🧠 Projeto e modelagem do banco de dados
- 🐍 Scripts Python para ingestão eficiente de dados
- 🧾 Criação de usuários e controle de permissões
- 📊 Tabelas analíticas segmentadas por tipo de produção
- 👁️ Views analíticas e consultas de exploração
- 📝 Documentação técnica para cada etapa
- 🧪 (Opcional) Estratégias de performance e backup

---

## 🗂️ 2. Estrutura do Projeto

A estrutura de pastas está organizada da seguinte forma:

homework/
├── docs/         # Documentação em Markdown (.md)
├── python/       # Scripts de ingestão com Python
├── sql/          # Scripts SQL (DDL, views, permissões, consultas)
└── README.md     # Guia geral do projeto

---

## 🧩 3. Schemas do Banco

O banco está dividido em dois schemas principais:

### 🔹 `raw_data`
Contém os dados brutos diretamente ingeridos dos arquivos `.txt`.

| Tabela     | Descrição                          |
|------------|------------------------------------|
| `producao` | Informações sobre produções        |
| `pessoa`   | Pessoas envolvidas                 |
| `equipe`   | Relação entre pessoas e produções  |

### 🔸 `analytics`
Contém as tabelas especializadas e views analíticas.

| Tabela                       | Tipo de produção                      |
|-----------------------------|----------------------------------------|
| `movies`                    | Filmes                                |
| `tv_shows`                  | Séries de TV                          |
| `video_games`               | Jogos eletrônicos                     |
| `documentaries`             | Documentários                         |
| `short_films`               | Curtas-metragens                      |
| `music_videos`              | Videoclipes                           |
| `theater_productions`       | Produções teatrais                    |
| `web_series`                | Séries da Web                         |
| `animations`                | Animações                             |

---

## 👥 4. Usuários e Permissões

Foram criados usuários específicos com permissões restritas:

| Usuário             | Acesso a...                        |
|---------------------|------------------------------------|
| `analyst_movies`    | Apenas dados de filmes             |
| `analyst_tv`        | Apenas séries de TV                |
| `analyst_games`     | Apenas videogames                  |
| `analyst_docs`      | Apenas documentários               |
| `analyst_all`       | Leitura de todos os dados          |
| `data_scientist`    | Leitura e escrita em `analytics`   |

Scripts usados: `sql/04_gerenciamento_usuarios.sql`

---

## 📈 5. Views Analíticas Criadas

### `production_summary`
Total de produções por tipo.

### `top_actors_by_type`
Top atores/atrizes com mais participações por tipo de produção.

### `yearly_production_trends`
Tendência de produções ao longo dos anos.

### `crew_analysis`
Papéis mais comuns em produções.

---

## 🔎 6. Consultas Realizadas

- Tipo de produção com mais registros
- Top 10 atores com mais participações
- Evolução da produção nos últimos 50 anos
- Anos com maior número de produções
- Porcentagem de produções com papéis definidos

⸻

🧠 Autor

Nome: Ariel Guiliane
Curso: Administrador de Banco de Dados (DBA)

⸻

🏁 Status

✅ Fases 1 a 4 concluídas
🔜 Fase 5 (Performance & Backup): pendente (opcional)