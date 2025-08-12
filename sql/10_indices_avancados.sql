CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- BRIN para varreduras por ano
CREATE INDEX IF NOT EXISTS ix_producao_ano_brin
  ON raw_data.producao USING brin (ano_producao);

-- GIN trigram para buscas textuais
CREATE INDEX IF NOT EXISTS ix_producao_titulo_trgm
  ON raw_data.producao USING gin (LOWER(titulo) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS ix_equipe_papel_trgm
  ON raw_data.equipe USING gin (LOWER(papel) gin_trgm_ops);
