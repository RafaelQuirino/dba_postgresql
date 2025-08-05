
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