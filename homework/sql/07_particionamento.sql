-- para descobrir quantas pessoas têm por primeira letra do nome
SELECT
  UPPER(LEFT(nome, 1)) AS primeira_letra,
  COUNT(*) AS total_pessoas
FROM raw_data.pessoa
GROUP BY UPPER(LEFT(nome, 1))
ORDER BY primeira_letra;

-- Para descobrir quantas pessoas estão em cada produção
SELECT
  e.producao_id,
  COUNT(e.pessoa_id) AS total_pessoas
FROM raw_data.equipe e
GROUP BY e.producao_id
ORDER BY total_pessoas DESC;


-- Particionamento da tabela pessoa no schema analytics por primeira letra do nome (A-Z + outros)
CREATE TABLE IF NOT EXISTS analytics.pessoa (
  pessoa_id BIGINT NOT NULL,
  nome TEXT NOT NULL,
  primeira_letra CHAR(1) NOT NULL,
  PRIMARY KEY (primeira_letra, pessoa_id)
) PARTITION BY LIST (primeira_letra);

-- Partições para cada letra do alfabeto latino
CREATE TABLE IF NOT EXISTS analytics.pessoa_a PARTITION OF analytics.pessoa FOR VALUES IN ('A');
CREATE TABLE IF NOT EXISTS analytics.pessoa_b PARTITION OF analytics.pessoa FOR VALUES IN ('B');
CREATE TABLE IF NOT EXISTS analytics.pessoa_c PARTITION OF analytics.pessoa FOR VALUES IN ('C');
CREATE TABLE IF NOT EXISTS analytics.pessoa_d PARTITION OF analytics.pessoa FOR VALUES IN ('D');
CREATE TABLE IF NOT EXISTS analytics.pessoa_e PARTITION OF analytics.pessoa FOR VALUES IN ('E');
CREATE TABLE IF NOT EXISTS analytics.pessoa_f PARTITION OF analytics.pessoa FOR VALUES IN ('F');
CREATE TABLE IF NOT EXISTS analytics.pessoa_g PARTITION OF analytics.pessoa FOR VALUES IN ('G');
CREATE TABLE IF NOT EXISTS analytics.pessoa_h PARTITION OF analytics.pessoa FOR VALUES IN ('H');
CREATE TABLE IF NOT EXISTS analytics.pessoa_i PARTITION OF analytics.pessoa FOR VALUES IN ('I');
CREATE TABLE IF NOT EXISTS analytics.pessoa_j PARTITION OF analytics.pessoa FOR VALUES IN ('J');
CREATE TABLE IF NOT EXISTS analytics.pessoa_k PARTITION OF analytics.pessoa FOR VALUES IN ('K');
CREATE TABLE IF NOT EXISTS analytics.pessoa_l PARTITION OF analytics.pessoa FOR VALUES IN ('L');
CREATE TABLE IF NOT EXISTS analytics.pessoa_m PARTITION OF analytics.pessoa FOR VALUES IN ('M');
CREATE TABLE IF NOT EXISTS analytics.pessoa_n PARTITION OF analytics.pessoa FOR VALUES IN ('N');
CREATE TABLE IF NOT EXISTS analytics.pessoa_o PARTITION OF analytics.pessoa FOR VALUES IN ('O');
CREATE TABLE IF NOT EXISTS analytics.pessoa_p PARTITION OF analytics.pessoa FOR VALUES IN ('P');
CREATE TABLE IF NOT EXISTS analytics.pessoa_q PARTITION OF analytics.pessoa FOR VALUES IN ('Q');
CREATE TABLE IF NOT EXISTS analytics.pessoa_r PARTITION OF analytics.pessoa FOR VALUES IN ('R');
CREATE TABLE IF NOT EXISTS analytics.pessoa_s PARTITION OF analytics.pessoa FOR VALUES IN ('S');
CREATE TABLE IF NOT EXISTS analytics.pessoa_t PARTITION OF analytics.pessoa FOR VALUES IN ('T');
CREATE TABLE IF NOT EXISTS analytics.pessoa_u PARTITION OF analytics.pessoa FOR VALUES IN ('U');
CREATE TABLE IF NOT EXISTS analytics.pessoa_v PARTITION OF analytics.pessoa FOR VALUES IN ('V');
CREATE TABLE IF NOT EXISTS analytics.pessoa_w PARTITION OF analytics.pessoa FOR VALUES IN ('W');
CREATE TABLE IF NOT EXISTS analytics.pessoa_x PARTITION OF analytics.pessoa FOR VALUES IN ('X');
CREATE TABLE IF NOT EXISTS analytics.pessoa_y PARTITION OF analytics.pessoa FOR VALUES IN ('Y');
CREATE TABLE IF NOT EXISTS analytics.pessoa_z PARTITION OF analytics.pessoa FOR VALUES IN ('Z');

-- Partição default para nomes que não começam com letras latinas
CREATE TABLE IF NOT EXISTS analytics.pessoa_others PARTITION OF analytics.pessoa DEFAULT;

-- Migrar dados da tabela raw_data.pessoa para analytics.pessoa
INSERT INTO analytics.pessoa (pessoa_id, primeira_letra, nome) SELECT pessoa_id, UPPER(LEFT(nome, 1)), nome FROM raw_data.pessoa;


-- Particionamento da tabela equipe no schema analytics usando HASH em 42 partições
CREATE TABLE IF NOT EXISTS analytics.equipe (
  pessoa_id BIGINT NOT NULL,
  producao_id BIGINT NOT NULL,
  papel TEXT,
  PRIMARY KEY (producao_id, pessoa_id)
) PARTITION BY HASH (producao_id);

-- Criar 42 partições hash
DO $$
DECLARE
  i integer;
BEGIN
  FOR i IN 0..41 LOOP
    EXECUTE format('CREATE TABLE IF NOT EXISTS analytics.equipe_hash_%s PARTITION OF analytics.equipe FOR VALUES WITH (MODULUS 42, REMAINDER %s);', i, i);
  END LOOP;
END$$;

-- Migrar dados da tabela raw_data.equipe para analytics.equipe
INSERT INTO analytics.equipe (pessoa_id, producao_id, papel)
SELECT pessoa_id, producao_id, papel FROM raw_data.equipe;

-- Índices para a tabela particionada analytics.pessoa
CREATE INDEX IF NOT EXISTS idx_pessoa_part_nome ON analytics.pessoa(nome);
CREATE INDEX IF NOT EXISTS idx_pessoa_part_primeira_letra ON analytics.pessoa(primeira_letra);

-- Índices para a tabela particionada analytics.equipe
CREATE INDEX IF NOT EXISTS idx_equipe_part_pessoa_id ON analytics.equipe(pessoa_id);
CREATE INDEX IF NOT EXISTS idx_equipe_part_producao_id ON analytics.equipe(producao_id);
CREATE INDEX IF NOT EXISTS idx_equipe_part_papel ON analytics.equipe(papel);