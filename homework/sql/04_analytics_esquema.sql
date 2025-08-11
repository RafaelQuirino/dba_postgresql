-- Criação do esquema analytics e tabelas especializadas para cada tipo de produção

CREATE SCHEMA IF NOT EXISTS analytics;

-- Filmes
CREATE TABLE IF NOT EXISTS analytics.movies AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 1;

-- Séries de TV
CREATE TABLE IF NOT EXISTS analytics.tv_shows AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 2;

-- Videogames
CREATE TABLE IF NOT EXISTS analytics.video_games AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 3;

-- Documentários
CREATE TABLE IF NOT EXISTS analytics.documentaries AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 4;

-- Curtas-metragens
CREATE TABLE IF NOT EXISTS analytics.short_films AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 5;

-- Clipes de Música
CREATE TABLE IF NOT EXISTS analytics.music_videos AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 6;

-- Produções Teatrais
CREATE TABLE IF NOT EXISTS analytics.theater_productions AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 7;

-- Séries Web
CREATE TABLE IF NOT EXISTS analytics.web_series AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 8;

-- Animações
CREATE TABLE IF NOT EXISTS analytics.animations AS
SELECT * FROM raw_data.producao WHERE producao_tipo_id = 9;

-- Índices para performance (exemplo para movies)
CREATE INDEX IF NOT EXISTS idx_movies_ano_producao ON analytics.movies(ano_producao);
CREATE INDEX IF NOT EXISTS idx_movies_titulo ON analytics.movies(titulo);

-- Repita índices para outras tabelas conforme necessário
