-- DDL Fase 1

-- 1) Criando o BD
CREATE DATABASE cinetech_productions;

-- 2) Criando o Schema
CREATE SCHEMA raw_data;

-- 2) Definindo o Schema padrão
SET search_path TO raw_data;

-- 2) Criando as tabelas
CREATE TABLE Pessoa (
    pessoaID INT PRIMARY KEY,
    nome VARCHAR(255)
);

CREATE TABLE Producao (
    producaoID INT PRIMARY KEY,
    titulo VARCHAR(255),
    ano_producao INT,
    tipo_ID INT 
);

CREATE TABLE Equipe (
    pessoaID INT,
    producaoID INT,
    papel TEXT,

    PRIMARY KEY (pessoaID, producaoID),
    FOREIGN KEY (pessoaID) REFERENCES Pessoa(pessoaID),
    FOREIGN KEY (producaoID) REFERENCES Producao(producaoID)
);

-- Estratégias de indexação para performance
CREATE INDEX idx_producao_ano ON Producao(ano_producao);
CREATE INDEX idx_titulo ON Producao(titulo);
CREATE INDEX idx_tipo_ID ON Producao(tipo_ID);
CREATE INDEX idx_nome ON Pessoa(nome);

-- DDL Fase 2

-- 1) Criando o Schema
CREATE SCHEMA analytics;

-- 1) Definindo o Schema padrão
SET search_path TO analytics;

-- Filmes 1
-- Animações 2
-- Curtas-metragens 3
-- Documentários 4
-- Clipes de Música 5
-- Videogames 6
-- Séries de TV 7

-- 5) Criando as tabelas movies
CREATE TABLE analytics.movies (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE movies_1500 PARTITION OF analytics.movies
FOR VALUES FROM (1500) TO (2000);

CREATE TABLE movies_2000 PARTITION OF analytics.movies
FOR VALUES FROM (2000) TO (2025);

CREATE TABLE movies_outros PARTITION OF analytics.movies DEFAULT;

-- 5) Criando as tabelas tv_shows
CREATE TABLE analytics.tv_shows (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE tv_shows_1500 PARTITION OF analytics.tv_shows
FOR VALUES FROM (1500) TO (2000);

CREATE TABLE tv_shows_2000 PARTITION OF analytics.tv_shows
FOR VALUES FROM (2000) TO (2025);

-- 5) Criando as tabelas video_games 
CREATE TABLE analytics.video_games (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE video_games_1500 PARTITION OF analytics.video_games
FOR VALUES FROM (1500) TO (2000);

CREATE TABLE video_games_2000 PARTITION OF analytics.video_games
FOR VALUES FROM (2000) TO (2025);

CREATE TABLE video_games_outros PARTITION OF analytics.video_games DEFAULT;

-- 5) Criando as tabelas documentaries
CREATE TABLE analytics.documentaries (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE documentaries_1900 PARTITION OF analytics.documentaries
FOR VALUES FROM (1900) TO (2025);

CREATE TABLE documentaries_outros PARTITION OF analytics.documentaries DEFAULT;

-- 5) Criando as tabelas short_films
CREATE TABLE analytics.short_films (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE short_films_1900 PARTITION OF analytics.short_films
FOR VALUES FROM (1900) TO (2025);

CREATE TABLE short_films_outros PARTITION OF analytics.short_films DEFAULT;

-- 5) Criando as tabelas music_videos
CREATE TABLE analytics.music_videos (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE music_videos_1900 PARTITION OF analytics.music_videos
FOR VALUES FROM (1900) TO (2025);

CREATE TABLE music_videos_outros PARTITION OF analytics.music_videos DEFAULT;

-- 5) Criando as tabelas animations
CREATE TABLE analytics.animations (
	id SERIAL,
    titulo VARCHAR(255),
	ano_producao INT,
    nome_pessoa VARCHAR(255),
	papel TEXT,
	
    PRIMARY KEY (id, ano_producao)
) PARTITION BY RANGE (ano_producao);

CREATE TABLE animations_1900 PARTITION OF analytics.animations
FOR VALUES FROM (1900) TO (2025);

CREATE TABLE animations_outros PARTITION OF analytics.animations DEFAULT;