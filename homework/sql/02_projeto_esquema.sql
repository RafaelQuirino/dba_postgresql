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

-- Schema para os dados brutos, as tabelas físicas.
CREATE SCHEMA raw_data;

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



