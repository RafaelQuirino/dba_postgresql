
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

