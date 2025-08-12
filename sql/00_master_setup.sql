-----------------------------------------------------------------
-- SCRIPT MESTRE DE SETUP - ANALYTICS E USUÁRIOS (VERSÃO COMPLETA)
-----------------------------------------------------------------

-- PASSO 1: LIMPEZA COMPLETA E ROBUSTA
DROP SCHEMA IF EXISTS analytics CASCADE;
DO $$
DECLARE
  role_name TEXT;
BEGIN
  FOREACH role_name IN ARRAY ARRAY['analyst_movies', 'analyst_tv', 'analyst_games', 'analyst_docs', 'analyst_all', 'data_scientist']
  LOOP
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = role_name) THEN
      EXECUTE 'REVOKE ALL ON SCHEMA raw_data FROM ' || quote_ident(role_name) || ';';
      EXECUTE 'REVOKE ALL ON ALL TABLES IN SCHEMA raw_data FROM ' || quote_ident(role_name) || ';';
      EXECUTE 'DROP ROLE ' || quote_ident(role_name) || ';';
    END IF;
  END LOOP;
END;
$$;

-- PASSO 2: RECRIAÇÃO DO SCHEMA ANALYTICS
CREATE SCHEMA analytics;

-- PASSO 3: RECRIAÇÃO DAS TABELAS SEGMENTADAS
CREATE TABLE analytics.movies AS SELECT * FROM raw_data.producao WHERE tipo_id = 1;
CREATE TABLE analytics.tv_shows AS SELECT * FROM raw_data.producao WHERE tipo_id = 2;
CREATE TABLE analytics.documentaries AS SELECT * FROM raw_data.producao WHERE tipo_id = 3;
CREATE TABLE analytics.videos AS SELECT * FROM raw_data.producao WHERE tipo_id = 4;
CREATE TABLE analytics.video_games AS SELECT * FROM raw_data.producao WHERE tipo_id = 6;
CREATE TABLE analytics.tv_episodes AS SELECT * FROM raw_data.producao WHERE tipo_id = 7;

CREATE INDEX ON analytics.movies (ano_producao);
CREATE INDEX ON analytics.tv_shows (ano_producao);
CREATE INDEX ON analytics.documentaries (ano_producao);

-- PASSO 4: RECRIAÇÃO DAS VIEWS ANALÍTICAS 
CREATE VIEW analytics.production_summary AS
SELECT 'Filmes' AS production_type, COUNT(*) AS total_productions FROM analytics.movies
UNION ALL
SELECT 'Séries de TV', COUNT(*) FROM analytics.tv_shows
UNION ALL
SELECT 'Documentários', COUNT(*) FROM analytics.documentaries
UNION ALL
SELECT 'Videogames', COUNT(*) FROM analytics.video_games;

CREATE VIEW analytics.top_actors_by_type AS
WITH ActorAppearances AS (
    SELECT p.nome, prod.tipo_id, COUNT(*) as total_roles
    FROM raw_data.pessoa p
    JOIN raw_data.equipe e ON p.pessoa_id = e.pessoa_id
    JOIN raw_data.producao prod ON e.producao_id = prod.producao_id
    WHERE e.papel NOT IN ('director', 'writer', 'producer', 'composer')
    GROUP BY p.nome, prod.tipo_id
), RankedActors AS (
    SELECT nome, tipo_id, total_roles, ROW_NUMBER() OVER(PARTITION BY tipo_id ORDER BY total_roles DESC) as rank
    FROM ActorAppearances
)
SELECT nome, CASE WHEN tipo_id = 1 THEN 'Filme' WHEN tipo_id = 2 THEN 'Série de TV' WHEN tipo_id = 3 THEN 'Documentário' ELSE 'Outro' END as production_type, total_roles
FROM RankedActors WHERE rank <= 10;

CREATE VIEW analytics.yearly_production_trends AS
SELECT ano_producao, COUNT(*) as total_productions
FROM raw_data.producao
WHERE ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
GROUP BY ano_producao
ORDER BY ano_producao;

-- PASSO 5: RECRIAÇÃO DOS USUÁRIOS E PERMISSÕES
CREATE ROLE analyst_movies LOGIN PASSWORD 'senha_forte_movies';
CREATE ROLE analyst_tv LOGIN PASSWORD 'senha_forte_tv';
CREATE ROLE analyst_games LOGIN PASSWORD 'senha_forte_games';
CREATE ROLE analyst_docs LOGIN PASSWORD 'senha_forte_docs';
CREATE ROLE analyst_all LOGIN PASSWORD 'senha_forte_all';
CREATE ROLE data_scientist LOGIN PASSWORD 'senha_forte_ds';

GRANT USAGE ON SCHEMA analytics, raw_data TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;
GRANT SELECT ON TABLE raw_data.pessoa, raw_data.equipe TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;
GRANT SELECT ON TABLE analytics.movies TO analyst_movies;
GRANT SELECT ON TABLE analytics.tv_shows TO analyst_tv;
GRANT SELECT ON TABLE analytics.video_games TO analyst_games;
GRANT SELECT ON TABLE analytics.documentaries TO analyst_docs;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO data_scientist;
GRANT CREATE ON SCHEMA analytics TO data_scientist;
GRANT analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist TO postgres;