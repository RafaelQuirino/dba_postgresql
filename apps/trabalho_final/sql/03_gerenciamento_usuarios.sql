-- Roles e GRANTs

CREATE ROLE analyst_movies WITH LOGIN PASSWORD 'senha_movies';
CREATE ROLE analyst_tv     WITH LOGIN PASSWORD 'senha_tv';
CREATE ROLE analyst_games  WITH LOGIN PASSWORD 'senha_games';
CREATE ROLE analyst_docs   WITH LOGIN PASSWORD 'senha_docs';
CREATE ROLE analyst_all    WITH LOGIN PASSWORD 'senha_all';
CREATE ROLE data_scientist WITH LOGIN PASSWORD 'senha_data';

GRANT USAGE ON SCHEMA analytics TO analyst_movies;
GRANT SELECT ON analytics.movies TO analyst_movies;

GRANT USAGE ON SCHEMA analytics TO analyst_tv;
GRANT SELECT ON analytics.tv_shows TO analyst_tv;

GRANT USAGE ON SCHEMA analytics TO analyst_games;
GRANT SELECT ON analytics.video_games TO analyst_games;

GRANT USAGE ON SCHEMA analytics TO analyst_docs;
GRANT SELECT ON analytics.documentaries TO analyst_docs;

GRANT USAGE ON SCHEMA analytics TO analyst_all;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO analyst_all;

GRANT USAGE ON SCHEMA analytics TO data_scientist;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_scientist;