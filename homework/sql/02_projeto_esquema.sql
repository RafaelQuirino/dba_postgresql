-- Tabela Produção
CREATE TABLE producao(
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255) NOT NULL,
	ano_producao INT NOT NULL,
	tipo_ID INT NOT NULL
);

-- Tabela Pessoa
CREATE TABLE pessoa(
	pessoaID INT PRIMARY KEY,
	nome VARCHAR(255) NOT NULL
);

-- Tabela Equipe
CREATE TABLE equipe(
	producaoID INTEGER NOT NULL REFERENCES producao(producaoID) ON DELETE CASCADE,
    pessoaID INTEGER NOT NULL REFERENCES pessoa(pessoaID) ON DELETE CASCADE,
	papel TEXT,
    
	PRIMARY KEY(producaoID, pessoaID)	
);

-- ########################### RAW_DATA SCHEMA ###########################

-- Schema raw_data, se ainda não existir
CREATE SCHEMA IF NOT EXISTS raw_data;

-- Este script move todos os objetos do 'public' para o 'raw_data'
DO $$
DECLARE
row record;
BEGIN
-- Mover todas as tabelas
FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA
raw_data;';
END LOOP;
-- Mover todas as views
FOR row IN SELECT viewname FROM pg_views WHERE schemaname = 'public' LOOP
EXECUTE 'ALTER VIEW public.' || quote_ident(row.viewname) || ' SET SCHEMA raw_data;';
END LOOP;
-- Mover todas as sequências
FOR row IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'public' LOOP
EXECUTE 'ALTER SEQUENCE public.' || quote_ident(row.sequencename) || ' SET SCHEMA
raw_data;';
END LOOP;
END;
$$;

-- ########################### ANALYTICS SCHEMA  ###########################

-- Schema analytics, se ainda não existir
CREATE SCHEMA IF NOT EXISTS analytics;

-- Tabela analytics.movies
CREATE TABLE analytics.movies(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.movies
INSERT INTO analytics.movies(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 1;

-- Tabela analytics.tv_shows
CREATE TABLE analytics.tv_shows(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.tv_shows
INSERT INTO analytics.tv_shows(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 2;

-- Tabela analytics.short_films
CREATE TABLE analytics.short_films(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.short_films
INSERT INTO analytics.short_films(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 3;

-- Tabela analytics.independent_films
CREATE TABLE analytics.independent_films(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.independent_films
INSERT INTO analytics.independent_films(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 4;

-- Tabela analytics.documentaries
CREATE TABLE analytics.documentaries(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.documentaries
INSERT INTO analytics.documentaries(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 5;

-- Tabela analytics.video_games
CREATE TABLE analytics.video_games(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.video_games
INSERT INTO analytics.video_games(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 6;

-- Tabela analytics.episodes
CREATE TABLE analytics.episodes(
  movieid SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  ano_producao INTEGER
);

-- Insere dados na Tabela analytics.episodes
INSERT INTO analytics.episodes(titulo, ano_producao)
SELECT titulo, ano_producao
FROM raw_data.producao
WHERE tipo_id = 7;
