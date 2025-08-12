-- Tabelas brutas com PK/FK/constraints
CREATE TABLE IF NOT EXISTS raw_data.producao(
  producao_id   BIGINT PRIMARY KEY,
  titulo        TEXT NOT NULL,
  ano_producao  INT CHECK (ano_producao BETWEEN 1870 AND EXTRACT(YEAR FROM CURRENT_DATE)::INT),
  tipo_id       INT
);

CREATE TABLE IF NOT EXISTS raw_data.pessoa(
  pessoa_id BIGINT PRIMARY KEY,
  nome      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.equipe(
  pessoa_id   BIGINT REFERENCES raw_data.pessoa(pessoa_id),
  producao_id BIGINT REFERENCES raw_data.producao(producao_id),
  papel       TEXT,
  PRIMARY KEY (pessoa_id, producao_id)
);

-- Índices básicos (B-tree)
CREATE INDEX IF NOT EXISTS ix_producao_tipo ON raw_data.producao(tipo_id);
CREATE INDEX IF NOT EXISTS ix_producao_ano  ON raw_data.producao(ano_producao);
CREATE INDEX IF NOT EXISTS ix_equipe_prod   ON raw_data.equipe(producao_id);
CREATE INDEX IF NOT EXISTS ix_equipe_pess   ON raw_data.equipe(pessoa_id);
