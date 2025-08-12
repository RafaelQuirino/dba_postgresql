-- Usuários exigidos
CREATE USER analyst_movies PASSWORD 'senha_movies';
CREATE USER analyst_tv     PASSWORD 'senha_tv';
CREATE USER analyst_games  PASSWORD 'senha_games';
CREATE USER analyst_docs   PASSWORD 'senha_docs';
CREATE USER analyst_all    PASSWORD 'senha_all';
CREATE USER data_scientist PASSWORD 'senha_ds';

-- Acesso leitura por tipo
GRANT USAGE ON SCHEMA analytics TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all;

GRANT SELECT ON analytics.movies              TO analyst_movies;
GRANT SELECT ON analytics.tv_shows            TO analyst_tv;
GRANT SELECT ON analytics.video_games         TO analyst_games;
GRANT SELECT ON analytics.documentaries       TO analyst_docs;

-- Leitura total (analytics)
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

-- Escrita para data_scientist (se precisar criar tabelas auxiliares no analytics)
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

-- Testes simples
SET ROLE analyst_movies; SELECT COUNT(*) FROM analytics.movies; RESET ROLE;
SET ROLE analyst_tv;     SELECT COUNT(*) FROM analytics.tv_shows; RESET ROLE;
