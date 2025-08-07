-- Cria o schema se não existir
CREATE SCHEMA IF NOT EXISTS raw_data;

-- Tabela: produção
CREATE TABLE IF NOT EXISTS raw_data.producao (
    id_producao BIGINT PRIMARY KEY,
    titulo TEXT,
    ano INT,
    tipo_id TEXT,
    quantidade INT
);

-- Tabela: pessoa
CREATE TABLE IF NOT EXISTS raw_data.pessoa (
    id_pessoa BIGINT PRIMARY KEY,
    nome TEXT
);

-- Tabela: equipe
CREATE TABLE IF NOT EXISTS raw_data.equipe (
    id_pessoa BIGINT,
    id_producao BIGINT,
    papel TEXT,
    PRIMARY KEY (id_pessoa, id_producao),
    FOREIGN KEY (id_pessoa) REFERENCES raw_data.pessoa(id_pessoa),
    FOREIGN KEY (id_producao) REFERENCES raw_data.producao(id_producao)
);

-- Converter os .parquet para .csv (por exemplo, via Pandas: df.to_csv('arquivo.csv'))
-- Usar comandos SQL como este para importar os dados:

-- Exemplo: importar CSV para a tabela raw_data.producao
COPY raw_data.producao (id_producao, titulo, ano, tipo_id, quantidade)
FROM '/caminho/para/producao_filtrado.csv'
DELIMITER ',' CSV HEADER;

-- Exemplo: importar CSV para a tabela raw_data.pessoa
COPY raw_data.pessoa (id_pessoa, nome)
FROM '/caminho/para/pessoa.csv'
DELIMITER ',' CSV HEADER;

-- Exemplo: importar CSV para a tabela raw_data.equipe
COPY raw_data.equipe (id_pessoa, id_producao, papel)
FROM '/caminho/para/equipe.csv'
DELIMITER ',' CSV HEADER;
