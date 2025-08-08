-- Criação do schema
CREATE SCHEMA IF NOT EXISTS analytics;

-- Define o schema como padrão
SET search_path TO analytics;

-- movies - Todas as produções de filmes 
CREATE TABLE analytics.movies (
	producaoID INT,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT,
	PRIMARY KEY (producaoID, ano_producao)
) PARTITION BY RANGE (ano_producao);

-- Estratégia de Particionamento por década
CREATE TABLE analytics.movies_1980s PARTITION OF analytics.movies
	FOR VALUES FROM (1980) TO (1990);
CREATE TABLE analytics.movies_1990s PARTITION OF analytics.movies
	FOR VALUES FROM (1990) TO (2000);
CREATE TABLE analytics.movies_2000s PARTITION OF analytics.movies
	FOR VALUES FROM (2000) TO (2010);
CREATE TABLE analytics.movies_2010s PARTITION OF analytics.movies
	FOR VALUES FROM (2010) TO (2020);
CREATE TABLE analytics.movies_2020s PARTITION OF analytics.movies
	FOR VALUES FROM (2020) TO (2030);

-- Tabela "default" para valores fora dos intervalos
CREATE TABLE analytics.movies_others PARTITION OF analytics.movies
	DEFAULT;

-- tv_shows - Todas as produções de séries de TV 
CREATE TABLE analytics.tv_shows (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- video_games - Todas as produções de videogames 
CREATE TABLE analytics.video_games (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- documentaries - Todas as produções de documentários
CREATE TABLE analytics.documentaries (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);


-- short_films - Todas as produções de curtas-metragens 
CREATE TABLE analytics.short_films (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- music_videos - Todas as produções de clipes de música 
CREATE TABLE analytics.music_videos (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- theater_productions - Todas as produções teatrais 
CREATE TABLE analytics.theater_productions (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- web_series - Todas as produções de séries web 
CREATE TABLE analytics.web_series (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);

-- animations - Todas as produções de animação 
CREATE TABLE analytics.animations (
	producaoID INT PRIMARY KEY,
	titulo VARCHAR(255),
	ano_producao INT,
	tipo_ID VARCHAR(50),
	nome_pessoa VARCHAR(255),
	papel TEXT
);


-- Estrategias de indexação
CREATE INDEX idx_movies_nome_pessoa ON analytics.movies(nome_pessoa);
CREATE INDEX idx_movies_titulo ON analytics.movies(titulo);
CREATE INDEX idx_tv_shows_nome_pessoa ON analytics.tv_shows(nome_pessoa);
CREATE INDEX idx_tv_shows_ano ON analytics.tv_shows(ano_producao);
CREATE INDEX idx_documentaries_nome_pessoa ON analytics.documentaries(nome_pessoa);

-- Estratégias de particionamento

/*
PARTITION BY RANGE - usado na linha 16
Partição por década - linhas 19 a 28
Partição default - linhas 31 e 32

*/