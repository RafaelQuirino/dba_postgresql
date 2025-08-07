-- Criação das tabelas de arquivamento (estrutura idêntica às originais)

CREATE SCHEMA IF NOT EXISTS archive_data;

CREATE TABLE IF NOT EXISTS archive_data.equipe (
    id_producao BIGINT,
    id_pessoa BIGINT,
    papel TEXT
);

CREATE TABLE IF NOT EXISTS archive_data.pessoa (
    id_pessoa BIGINT,
    nome TEXT
);

CREATE TABLE IF NOT EXISTS archive_data.producao (
    id_producao BIGINT,
    titulo TEXT,
    ano INTEGER,
    tipo_id INTEGER
);

-- Mover os dados problemáticos para essas tabelas

INSERT INTO archive_data.equipe
SELECT *
FROM raw_data.equipe
WHERE papel IS NULL;

DELETE FROM raw_data.equipe
WHERE papel IS NULL;

-- Exemplo: mover dados duplicados de pessoa
-- Insere apenas os duplicados (baseado na chave id_pessoa + nome)
INSERT INTO archive_data.pessoa
SELECT *
FROM raw_data.pessoa p
WHERE (p.id_pessoa, p.nome) IN (
  SELECT id_pessoa, nome
  FROM raw_data.pessoa
  GROUP BY id_pessoa, nome
  HAVING COUNT(*) > 1
);

-- Remove duplicados (mantendo uma ocorrência)
DELETE FROM raw_data.pessoa p
USING (
  SELECT id_pessoa, nome, MIN(ctid) as keep_row
  FROM raw_data.pessoa
  GROUP BY id_pessoa, nome
  HAVING COUNT(*) > 1
) dups
WHERE p.id_pessoa = dups.id_pessoa
  AND p.nome = dups.nome
  AND p.ctid <> dups.keep_row;

-- Consultas básicas nas tabelas de arquivamento
SELECT * FROM archive_data.equipe;

-- Ver registros arquivados da tabela pessoa
SELECT * FROM archive_data.pessoa;

-- Ver registros arquivados da tabela producao
SELECT * FROM archive_data.producao;

-- Ver quantos registros foram arquivados em cada tabela:
SELECT 'equipe' AS tabela, COUNT(*) AS total FROM archive_data.equipe
UNION ALL
SELECT 'pessoa', COUNT(*) FROM archive_data.pessoa
UNION ALL
SELECT 'producao', COUNT(*) FROM archive_data.producao;

-- Consultar apenas registros com valor NULL na coluna papel da equipe arquivada:
SELECT * FROM archive_data.equipe
WHERE papel IS NULL;

-- Ver os nomes duplicados arquivados da tabela pessoa:
SELECT id_pessoa, nome, COUNT(*) AS vezes
FROM archive_data.pessoa
GROUP BY id_pessoa, nome
HAVING COUNT(*) > 1;








