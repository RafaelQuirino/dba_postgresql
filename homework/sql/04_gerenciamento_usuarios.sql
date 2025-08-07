-- Criação dos usuários com senhas padrão
CREATE USER analyst_movies WITH PASSWORD '123';
CREATE USER analyst_tv WITH PASSWORD '123';
CREATE USER analyst_games WITH PASSWORD '123';
CREATE USER analyst_docs WITH PASSWORD '123';
CREATE USER analyst_all WITH PASSWORD '123';
CREATE USER data_scientist WITH PASSWORD '123';

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

-- Permissões futuras também
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_scientist;
