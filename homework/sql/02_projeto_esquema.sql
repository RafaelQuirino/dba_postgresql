CREATE SCHEMA raw_data;
CREATE SCHEMA analytics;

CREATE TABLE IF NOT EXISTS raw_data.producao_tipo (
	producao_tipo_id INTEGER PRIMARY KEY,
	nome VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.producao (
	producao_id BIGINT PRIMARY KEY,
	titulo TEXT NOT NULL,
	ano_producao INTEGER,
	producao_tipo_id INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.pessoa (
	pessoa_id BIGINT PRIMARY KEY,
	nome TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.equipe (
	pessoa_id BIGINT NOT NULL,
	producao_id BIGINT NOT NULL,
	papel TEXT,
	PRIMARY KEY (producao_id, pessoa_id)
);
