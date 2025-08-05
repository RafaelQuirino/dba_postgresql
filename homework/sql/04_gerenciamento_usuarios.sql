 '''
1. **`analyst_movies`** - Pode acessar apenas dados relacionados a filmes
2. **`analyst_tv`** - Pode acessar apenas dados relacionados a séries de TV
3. **`analyst_games`** - Pode acessar apenas dados relacionados a videogames
4. **`analyst_docs`** - Pode acessar apenas dados relacionados a documentários
5. **`analyst_all`** - Pode acessar todos os dados analíticos (somente leitura)
6. **`data_scientist`** - Pode acessar todos os dados com permissões de escrita no esquema analytics
'''
 
CREATE ROLE analyst_movies NOLOGIN; -- Pode acessar apenas dados relacionados a filmes
CREATE ROLE analyst_tv NOLOGIN; --Pode acessar apenas dados relacionados a séries de TV
CREATE ROLE analyst_games NOLOGIN; -- Pode acessar apenas dados relacionados a videogames
CREATE ROLE analyst_docs NOLOGIN; -- Pode acessar apenas dados relacionados a documentários
CREATE ROLE analyst_all NOLOGIN; -- Pode acessar todos os dados analíticos (somente leitura)
CREATE ROLE data_scientist NOLOGIN; -- Pode acessar todos os dados com permissões de escrita no esquema analytics

CREATE ROLE job_data_analyst_jr NOLOGIN; -- Analista de dados Junior
CREATE ROLE job_data_analyst_pl NOLOGIN; -- Analista de dados Pleno
CREATE ROLE job_data_analyst_sr NOLOGIN; -- Analista de dados Senior
CREATE ROLE job_data_scientist	NOLOGIN; -- Ciência de dados

CREATE ROLE pedro_data_analista_jr WITH LOGIN PASSWORD 'teste#123';
CREATE ROLE jose_data_analista_pl WITH LOGIN PASSWORD 'teste#123';
CREATE ROLE carlos_data_analista_sr WITH LOGIN PASSWORD 'teste#123';
CREATE ROLE maria_data_scientist WITH LOGIN PASSWORD 'teste#123';

GRANT analyst_movies TO job_data_analyst_jr;
GRANT analyst_tv TO job_data_analyst_pl;
GRANT analyst_games TO job_data_analyst_pl;
GRANT analyst_docs TO job_data_analyst_pl;
GRANT analyst_all TO job_data_analyst_sr;
GRANT data_scientist TO job_data_scientist;

GRANT job_data_analyst_jr TO pedro_data_analista_jr;
GRANT job_data_analyst_pl TO jose_data_analista_pl;
GRANT job_data_analyst_sr TO carlos_data_analista_sr;
GRANT job_data_scientist TO maria_data_scientist;

GRANT USAGE ON SCHEMA analytics TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;
GRANT SELECT ON analytics.movies TO analyst_movies, analyst_all;
GRANT SELECT ON analytics.tv_shows TO analyst_tv, analyst_all;
GRANT SELECT ON analytics.video_games TO analyst_games, analyst_all;
GRANT SELECT ON analytics.documentaries TO analyst_docs, analyst_all;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

-- docker compose exec -u postgres postgresql bash
-- psql -U (user) -d cinetech_productions

-- Testes:

-- User pedro_data_analista_jr
-- SELECT * FROM analytics.movies LIMIT 5;
-- SELECT * FROM analytics.tv_shows LIMIT 5;
-- UPDATE analytics.animations SET papel = 'Father 2' WHERE id = 1

-- User jose_data_analista_pl
-- SELECT * FROM analytics.movies LIMIT 5;
-- SELECT * FROM analytics.tv_shows LIMIT 5;
-- UPDATE analytics.animations SET papel = 'Father 2' WHERE id = 1

-- User carlos_data_analista_sr 
-- SELECT * FROM analytics.movies LIMIT 5;
-- SELECT * FROM analytics.tv_shows LIMIT 5;
-- SELECT * FROM analytics.video_games LIMIT 5;
-- SELECT * FROM analytics.documentaries LIMIT 5;
-- UPDATE analytics.animations SET papel = 'Father 2' WHERE id = 1

-- User pedro_data_analista_jr
-- UPDATE analytics.animations SET papel = 'Father 2' WHERE id = 1



