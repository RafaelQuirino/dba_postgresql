/************************************************************************************
 * SCRIPT PARA A CAMADA GOLD (ANALYTICS)
 *
 * Versão: Final (Com Nomes de Coluna Amigáveis)
 * Objetivo: Criar Data Marts com um esquema simples e intuitivo para o usuário final.
 ************************************************************************************/

-- 1. Garante que o schema para a camada Gold exista
CREATE SCHEMA IF NOT EXISTS analytics;

-- 2. Remove as tabelas antigas para que o script possa ser executado novamente.
DROP TABLE IF EXISTS analytics.movies CASCADE;
DROP TABLE IF EXISTS analytics.tv_shows CASCADE;
DROP TABLE IF EXISTS analytics.documentaries CASCADE;
DROP TABLE IF EXISTS analytics.video_games CASCADE;
DROP TABLE IF EXISTS analytics.short_films CASCADE;
DROP TABLE IF EXISTS analytics.theater_productions CASCADE;
DROP TABLE IF EXISTS analytics.adult_films CASCADE;
DROP TABLE IF EXISTS analytics.uncategorized CASCADE;


--==================================================================================
-- CRIAÇÃO DAS TABELAS COM NOMES DE COLUNA CORRIGIDOS
--==================================================================================

-- Tabela: movies
CREATE TABLE analytics.movies AS
SELECT
    "producaoID" AS id,       -- RENOMEADO
    titulo,
    ano_producao AS ano       -- RENOMEADO
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Filme';

ALTER TABLE analytics.movies ADD PRIMARY KEY (id);          -- ATUALIZADO
CREATE INDEX idx_movies_titulo ON analytics.movies (titulo);
CREATE INDEX idx_movies_ano ON analytics.movies (ano);      -- ATUALIZADO


-- Tabela: tv_shows
CREATE TABLE analytics.tv_shows AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Série de TV';

ALTER TABLE analytics.tv_shows ADD PRIMARY KEY (id);
CREATE INDEX idx_tv_shows_titulo ON analytics.tv_shows (titulo);
CREATE INDEX idx_tv_shows_ano ON analytics.tv_shows (ano);


-- Tabela: documentaries
CREATE TABLE analytics.documentaries AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Documentário';

ALTER TABLE analytics.documentaries ADD PRIMARY KEY (id);
CREATE INDEX idx_documentaries_titulo ON analytics.documentaries (titulo);
CREATE INDEX idx_documentaries_ano ON analytics.documentaries (ano);


-- Tabela: video_games
CREATE TABLE analytics.video_games AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Videogame';

ALTER TABLE analytics.video_games ADD PRIMARY KEY (id);
CREATE INDEX idx_video_games_titulo ON analytics.video_games (titulo);
CREATE INDEX idx_video_games_ano ON analytics.video_games (ano);


-- Tabela: short_films (Curta-metragem)
CREATE TABLE analytics.short_films AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Curta-metragem';

ALTER TABLE analytics.short_films ADD PRIMARY KEY (id);
CREATE INDEX idx_short_films_titulo ON analytics.short_films (titulo);
CREATE INDEX idx_short_films_ano ON analytics.short_films (ano);


-- Tabela: theater_productions (Produção Teatral)
CREATE TABLE analytics.theater_productions AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Produção Teatral';

ALTER TABLE analytics.theater_productions ADD PRIMARY KEY (id);
CREATE INDEX idx_theater_productions_titulo ON analytics.theater_productions (titulo);
CREATE INDEX idx_theater_productions_ano ON analytics.theater_productions (ano);


-- Tabela: adult_films (Filmes Adultos)
CREATE TABLE analytics.adult_films AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Filmes Adultos';

ALTER TABLE analytics.adult_films ADD PRIMARY KEY (id);
CREATE INDEX idx_adult_films_titulo ON analytics.adult_films (titulo);
CREATE INDEX idx_adult_films_ano ON analytics.adult_films (ano);


-- Tabela: uncategorized (Não categorizado)
CREATE TABLE analytics.uncategorized AS
SELECT
    "producaoID" AS id,
    titulo,
    ano_producao AS ano
FROM
    trusted_data.vw_producoes
WHERE
    tipo_producao = 'Não categorizado';

ALTER TABLE analytics.uncategorized ADD PRIMARY KEY (id);
CREATE INDEX idx_uncategorized_titulo ON analytics.uncategorized (titulo);
CREATE INDEX idx_uncategorized_ano ON analytics.uncategorized (ano);

--==================================================================================
-- FIM DO SCRIPT
-- A camada Gold agora possui um esquema mais limpo e intuitivo.
--==================================================================================