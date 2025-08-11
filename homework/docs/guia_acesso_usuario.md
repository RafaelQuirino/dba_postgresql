# 👤 Guia de Acesso de Usuários - CineTech Studios

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)

Este documento apresenta os usuários definidos no banco cinetech_productions, com suas permissões e o respectivo alcance de acesso.

## 👥 Usuários e perfis:

| Usuários           | Senha                             | Finalidade                                |
|--------------------|-----------------------------------|-------------------------------------------|
| analyst_all        | senha_forte_para_analyst_all      | Acesso de leitura a todas as produções    |
| analyst_docs       | senha_forte_para_analyst_docs     | Consultar apenas documentários            |
| analyst_games      | senha_forte_para_analyst_games    | Consultar apenas videogames               |
| analyst_movies     | senha_forte_para_analyst_movies   | Consultar apenas produções do tipo filme  |
| analyst_tv_shows   | senha_forte_para_analyst_tv_shows | Consultar apenas produções de TV          |
| data_scientis      | senha_forte_para_data_scientis    | Leitura e escrita no schema analytics     |

## 🛡️ Permissões:

| Usuário         | SELECT | INSERT | UPDATE | DELETE | Tabelas com Acesso                 |
|-----------------|:------:|:------:|:------:|:------:|------------------------------------|
| analyst_all     |   ✅    |   ❌    |   ❌    |   ❌    | Todas do schema `analytics`        |
| analyst_docs    |   ✅    |   ❌    |   ❌    |   ❌    | `analytics.documentaries`          |
| analyst_games   |   ✅    |   ❌    |   ❌    |   ❌    | `analytics.video_games`            |
| analyst_movies  |   ✅    |   ❌    |   ❌    |   ❌    | `analytics.movies`                 |
| analyst_tv      |   ✅    |   ❌    |   ❌    |   ❌    | `analytics.tv_shows`               |
| data_scientist  |   ✅    |   ✅    |   ✅    |   ✅    | Todas do schema `analytics`        |

## 🛠️ Comandos

```sql
-- Roles de identidade (USUÁRIOS E SERVIÇOS)
CREATE ROLE analyst_movies WITH LOGIN PASSWORD 'senha_forte_para_analyst_movies';
CREATE ROLE analyst_tv WITH LOGIN PASSWORD 'senha_forte_para_analyst_tv';
CREATE ROLE analyst_games WITH LOGIN PASSWORD 'senha_forte_para_analyst_games';
CREATE ROLE analyst_all WITH LOGIN PASSWORD 'senha_forte_para_analyst_all';
CREATE ROLE data_scientist WITH LOGIN PASSWORD 'senha_forte_para_data_scientist';

-- Conceder permissões com GRANT
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_movies;
GRANT USAGE ON SCHEMA analytics TO analyst_movies;
GRANT SELECT ON analytics.movies TO analyst_movies;

-- analyst_tv
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_tv;
GRANT USAGE ON SCHEMA analytics TO analyst_tv;
GRANT SELECT ON analytics.tv_shows TO analyst_tv;

-- analyst_games
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_games;
GRANT USAGE ON SCHEMA analytics TO analyst_games;
GRANT SELECT ON analytics.video_games TO analyst_games;

-- analyst_docs
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_docs;
GRANT USAGE ON SCHEMA analytics TO analyst_docs;
GRANT SELECT ON analytics.documentaries TO analyst_docs;

-- analyst_all
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_all;
GRANT USAGE ON SCHEMA analytics TO analyst_all;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

-- Garante acesso futuro também
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO analyst_all;

-- data_scientist
GRANT CONNECT ON DATABASE cinetech_productions TO data_scientist;
GRANT USAGE ON SCHEMA analytics TO data_scientist;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

```
## 🧪 Testes: 
- Todos os usuários foram testados com SET ROLE no ambiente PostgreSQL.
- Erros esperados (permission denied) confirmaram o isolamento correto por tabela.

## 📸 Evidências dos Testes: 

- **Ativar o contexto do usuário**
```sql
SET ROLE analyst_docs;
```
- **Espera-se que haja permissão**
```sql
SELECT * FROM analytics.documentaries LIMIT 10;
```
![](homework/docs/imagem1.png)

- **Espera-se que não haja permissão**

```sql
SELECT * FROM analytics.movies LIMIT 10;
```
- **Retorna para o usuário padrão (postgres):**

```sql
RESET ROLE;
```





