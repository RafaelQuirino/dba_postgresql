

-- DROP DATABASE IF EXISTS cinetech_productions;

CREATE DATABASE cinetech_productions
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	

-- Producao (producaoID, titulo, ano_produção, tipo_ID)
CREATE TABLE raw_data.producao (
    producaoID INT PRIMARY KEY,
    titulo VARCHAR(255),
    ano_producao INT,
    tipo_ID INT
);

-- Pessoa (pessoaID, nome)
CREATE TABLE raw_data.pessoa (
    pessoaID INT PRIMARY KEY,
    nome VARCHAR(255)
);

-- Equipe (pessoaID, producaoID, papel)
CREATE TABLE raw_data.equipe (
    pessoaID INT,
    producaoID INT,
    papel TEXT,
    PRIMARY KEY (pessoaID, producaoID),
    FOREIGN KEY (pessoaID) REFERENCES raw_data.pessoa(pessoaID),
    FOREIGN KEY (producaoID) REFERENCES raw_data.producao(producaoID)
);


