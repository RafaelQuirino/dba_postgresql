CREATE SCHEMA IF NOT EXISTS raw_data;

-- Criação das tabelas brutas (producao, pessoa, equipe)
CREATE TABLE IF NOT EXISTS raw_data.producao (
    id_producao BIGINT PRIMARY KEY,
    titulo TEXT,
    ano INT,
    tipo_id TEXT,
    quantidade INT
);

CREATE TABLE IF NOT EXISTS raw_data.pessoa (
    id_pessoa BIGINT PRIMARY KEY,
    nome TEXT
);

CREATE TABLE IF NOT EXISTS raw_data.equipe (
    id_pessoa BIGINT,
    id_producao BIGINT,
    papel TEXT,
    PRIMARY KEY (id_pessoa, id_producao),
    FOREIGN KEY (id_pessoa) REFERENCES raw_data.pessoa(id_pessoa),
    FOREIGN KEY (id_producao) REFERENCES raw_data.producao(id_producao)
);

-- Criação do schema analytics
CREATE SCHEMA IF NOT EXISTS analytics;

-- Criação das tabelas analíticas por tipo de produção
-- Filmes
CREATE TABLE IF NOT EXISTS analytics.movies AS
SELECT * FROM raw_data.producao WHERE tipo_id = '1';

-- Séries de TV
CREATE TABLE IF NOT EXISTS analytics.tv_shows AS
SELECT * FROM raw_data.producao WHERE tipo_id = '2';

-- Documentários
CREATE TABLE IF NOT EXISTS analytics.documentaries AS
SELECT * FROM raw_data.producao WHERE tipo_id = '3';

-- Curtas-metragens
CREATE TABLE IF NOT EXISTS analytics.short_films AS
SELECT * FROM raw_data.producao WHERE tipo_id = '4';

-- Clipes de música
CREATE TABLE IF NOT EXISTS analytics.music_videos AS
SELECT * FROM raw_data.producao WHERE tipo_id = '5';

-- Videogames
CREATE TABLE IF NOT EXISTS analytics.video_games AS
SELECT * FROM raw_data.producao WHERE tipo_id = '6';

-- Animações
CREATE TABLE IF NOT EXISTS analytics.animations AS
SELECT * FROM raw_data.producao WHERE tipo_id = '7';

-- Produções teatrais (sem dados)
CREATE TABLE IF NOT EXISTS analytics.theater_productions (
    id_producao BIGINT,
    titulo TEXT,
    ano INT,
    tipo_id TEXT,
    quantidade INT
);

-- Séries Web (sem dados)
CREATE TABLE IF NOT EXISTS analytics.web_series (
    id_producao BIGINT,
    titulo TEXT,
    ano INT,
    tipo_id TEXT,
    quantidade INT
);

-- Índices para acelerar análises (por ano)
CREATE INDEX IF NOT EXISTS idx_movies_ano ON analytics.movies(ano);
CREATE INDEX IF NOT EXISTS idx_tv_shows_ano ON analytics.tv_shows(ano);
CREATE INDEX IF NOT EXISTS idx_video_games_ano ON analytics.video_games(ano);
CREATE INDEX IF NOT EXISTS idx_documentaries_ano ON analytics.documentaries(ano);
CREATE INDEX IF NOT EXISTS idx_short_films_ano ON analytics.short_films(ano);
CREATE INDEX IF NOT EXISTS idx_music_videos_ano ON analytics.music_videos(ano);
CREATE INDEX IF NOT EXISTS idx_animations_ano ON analytics.animations(ano);

-- Verificar quantidades em cada tabela
SELECT 'movies' AS tabela, COUNT(*) FROM analytics.movies
UNION ALL
SELECT 'tv_shows', COUNT(*) FROM analytics.tv_shows
UNION ALL
SELECT 'documentaries', COUNT(*) FROM analytics.documentaries
UNION ALL
SELECT 'short_films', COUNT(*) FROM analytics.short_films
UNION ALL
SELECT 'music_videos', COUNT(*) FROM analytics.music_videos
UNION ALL
SELECT 'video_games', COUNT(*) FROM analytics.video_games
UNION ALL
SELECT 'animations', COUNT(*) FROM analytics.animations;
