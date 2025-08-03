-- DDL

-- 1) Criando o BD
CREATE DATABASE cinetech_productions;

-- 2) Criando o Schema
CREATE SCHEMA raw_data;

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

