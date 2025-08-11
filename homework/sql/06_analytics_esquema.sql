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

CREATE INDEX IF NOT EXISTS idx_movies_ano_producao ON analytics.movies(ano_producao);
CREATE INDEX IF NOT EXISTS idx_movies_titulo ON analytics.movies(titulo);


-- Índices para performance nas demais tabelas
CREATE INDEX IF NOT EXISTS idx_tv_shows_ano_producao ON analytics.tv_shows(ano_producao);
CREATE INDEX IF NOT EXISTS idx_tv_shows_titulo ON analytics.tv_shows(titulo);

CREATE INDEX IF NOT EXISTS idx_video_games_ano_producao ON analytics.video_games(ano_producao);
CREATE INDEX IF NOT EXISTS idx_video_games_titulo ON analytics.video_games(titulo);

CREATE INDEX IF NOT EXISTS idx_documentaries_ano_producao ON analytics.documentaries(ano_producao);
CREATE INDEX IF NOT EXISTS idx_documentaries_titulo ON analytics.documentaries(titulo);

CREATE INDEX IF NOT EXISTS idx_short_films_ano_producao ON analytics.short_films(ano_producao);
CREATE INDEX IF NOT EXISTS idx_short_films_titulo ON analytics.short_films(titulo);

CREATE INDEX IF NOT EXISTS idx_music_videos_ano_producao ON analytics.music_videos(ano_producao);
CREATE INDEX IF NOT EXISTS idx_music_videos_titulo ON analytics.music_videos(titulo);

CREATE INDEX IF NOT EXISTS idx_theater_productions_ano_producao ON analytics.theater_productions(ano_producao);
CREATE INDEX IF NOT EXISTS idx_theater_productions_titulo ON analytics.theater_productions(titulo);

CREATE INDEX IF NOT EXISTS idx_web_series_ano_producao ON analytics.web_series(ano_producao);
CREATE INDEX IF NOT EXISTS idx_web_series_titulo ON analytics.web_series(titulo);

CREATE INDEX IF NOT EXISTS idx_animations_ano_producao ON analytics.animations(ano_producao);
CREATE INDEX IF NOT EXISTS idx_animations_titulo ON analytics.animations(titulo);

-- Consultas de verificação do número de registros em cada tabela
SELECT 'movies' AS tabela, COUNT(*) AS total FROM analytics.movies
UNION ALL
SELECT 'tv_shows', COUNT(*) FROM analytics.tv_shows
UNION ALL
SELECT 'video_games', COUNT(*) FROM analytics.video_games
UNION ALL
SELECT 'documentaries', COUNT(*) FROM analytics.documentaries
UNION ALL
SELECT 'short_films', COUNT(*) FROM analytics.short_films
UNION ALL
SELECT 'music_videos', COUNT(*) FROM analytics.music_videos
UNION ALL
SELECT 'theater_productions', COUNT(*) FROM analytics.theater_productions
UNION ALL
SELECT 'web_series', COUNT(*) FROM analytics.web_series
UNION ALL
SELECT 'animations', COUNT(*) FROM analytics.animations;
