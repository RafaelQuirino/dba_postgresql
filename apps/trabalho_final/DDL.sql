
-- Cria o banco de dados cinetech_productions
CREATE DATABASE cinetech_productions;

-- Seleciona o banco de dados cinetech_productions

-- Cria schema raw_data
CREATE SCHEMA IF NOT EXISTS raw_data;

-- Cria tabelas do raw data
CREATE TABLE IF NOT EXISTS raw_data.producoes (
    producao_id INT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    ano INT NOT NULL,
    tipo_id INT NOT NULL
);

CREATE INDEX idx_producoes_tipo_id ON raw_data.producoes(tipo_id);

CREATE TABLE IF NOT EXISTS raw_data.pessoas (
    pessoa_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.equipes (
    pessoa_id INT NOT NULL,
    producao_id INT NOT NULL,
    papel TEXT NOT NULL,
    PRIMARY KEY (pessoa_id, producao_id),
    FOREIGN KEY (pessoa_id) REFERENCES raw_data.pessoas(pessoa_id),
    FOREIGN KEY (producao_id) REFERENCES raw_data.producoes(producao_id)
);


--- Cria schema analytics
CREATE SCHEMA IF NOT EXISTS analytics;

-- Cria tabelas do analytics
CREATE TABLE IF NOT EXISTS analytics.production_types (
    tipo_id INT PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.tv_shows (
    tv_show_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.video_games (
    video_game_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.documentaries (
    documentary_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.short_films (
    short_film_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.music_videos (
    music_video_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.theater_productions (
    theater_production_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.web_series (
    web_series_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.animations (
    animation_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT NOT NULL
);
-- Cria person e crew
CREATE TABLE IF NOT EXISTS analytics.persons (
    person_id   INT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.crew (
    person_id        INT NOT NULL REFERENCES analytics.persons(person_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    production_type  VARCHAR(50) NOT NULL,
    production_id    INT NOT NULL,
    job              TEXT NOT NULL,
    PRIMARY KEY (person_id, production_type, production_id, job),
    CONSTRAINT crew_production_type_chk CHECK (production_type IN (
        'movie','tv_show','video_game','documentary','short_film',
        'music_video','theater','web_series','animation'
    ))
);

-- Índices úteis
CREATE INDEX IF NOT EXISTS idx_crew_production ON analytics.crew (production_type, production_id);
CREATE INDEX IF NOT EXISTS idx_crew_job ON analytics.crew (job);
CREATE INDEX IF NOT EXISTS idx_crew_person ON analytics.crew (person_id);

-- Cria roles

CREATE ROLE analyst_movies WITH LOGIN PASSWORD 'senha_movies';
CREATE ROLE analyst_tv WITH LOGIN PASSWORD 'senha_tv';
CREATE ROLE analyst_games WITH LOGIN PASSWORD 'senha_games';
CREATE ROLE analyst_docs WITH LOGIN PASSWORD 'senha_docs';
CREATE ROLE analyst_all WITH LOGIN PASSWORD 'senha_all';
CREATE ROLE data_scientist WITH LOGIN PASSWORD 'senha_data';

-- GRANTS
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

-- Para manter o acesso às futuras tabelas automaticamente:
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO analyst_all;

GRANT USAGE ON SCHEMA analytics TO data_scientist;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

-- Para manter o acesso total às futuras tabelas automaticamente:
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_scientist;