-- Tabelas de staging para leitura direta dos .txt
DROP TABLE IF EXISTS staging.producao;
CREATE TABLE staging.producao(
  producao_id BIGINT,
  titulo TEXT,
  ano_producao INT,
  tipo_id INT
);

DROP TABLE IF EXISTS staging.pessoa;
CREATE TABLE staging.pessoa(
  pessoa_id BIGINT,
  nome TEXT
);

DROP TABLE IF EXISTS staging.equipe;
CREATE TABLE staging.equipe(
  pessoa_id BIGINT,
  producao_id BIGINT,
  papel TEXT
);

-- Carrega usando COPY com delimitador '##' e codificação CP1252
TRUNCATE staging.producao, staging.pessoa, staging.equipe;

COPY staging.producao(producao_id,titulo,ano_producao,tipo_id)
FROM '/data/producao.txt'
WITH (FORMAT csv, DELIMITER '##', NULL '', HEADER false, ENCODING 'WIN1252');

COPY staging.pessoa(pessoa_id,nome)
FROM '/data/pessoa.txt'
WITH (FORMAT csv, DELIMITER '##', NULL '', HEADER false, ENCODING 'WIN1252');

COPY staging.equipe(pessoa_id,producao_id,papel)
FROM '/data/equipe.txt'
WITH (FORMAT csv, DELIMITER '##', NULL '', HEADER false, ENCODING 'WIN1252');

-- Limpeza e envio para raw_data com validações
INSERT INTO raw_data.producao(producao_id,titulo,ano_producao,tipo_id)
SELECT DISTINCT
  s.producao_id,
  NULLIF(BTRIM(s.titulo),'') AS titulo,
  NULLIF(s.ano_producao,0)   AS ano_producao,
  NULLIF(s.tipo_id,0)        AS tipo_id
FROM staging.producao s
WHERE s.producao_id IS NOT NULL
  AND BTRIM(s.titulo) <> '';

INSERT INTO raw_data.pessoa(pessoa_id,nome)
SELECT DISTINCT s.pessoa_id, NULLIF(BTRIM(s.nome),'')
FROM staging.pessoa s
WHERE s.pessoa_id IS NOT NULL
  AND BTRIM(s.nome) <> '';

INSERT INTO raw_data.equipe(pessoa_id,producao_id,papel)
SELECT DISTINCT
  e.pessoa_id, e.producao_id, NULLIF(BTRIM(e.papel),'')
FROM staging.equipe e
JOIN raw_data.producao p USING (producao_id)
JOIN raw_data.pessoa   pe ON pe.pessoa_id = e.pessoa_id;
