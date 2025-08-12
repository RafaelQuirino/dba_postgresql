-- 1) Tipo com mais produções
SELECT * FROM analytics.production_summary ORDER BY total DESC NULLS LAST;

-- 2) Top 10 atores (todos os tipos)
SELECT pe.nome, COUNT(*) AS participacoes
FROM raw_data.equipe e
JOIN raw_data.pessoa pe USING (pessoa_id)
GROUP BY pe.nome
ORDER BY participacoes DESC
LIMIT 10;

-- 3) Número de produções nos últimos 50 anos
SELECT * FROM analytics.yearly_production_trends
WHERE ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE)::INT - 50
ORDER BY ano_producao;

-- 4) Anos com maior produção (top 10)
SELECT ano_producao, COUNT(*) AS qtd
FROM raw_data.producao
GROUP BY ano_producao
ORDER BY qtd DESC
LIMIT 10;

-- 5) % de produções com papéis específicos
WITH marcados AS (
  SELECT DISTINCT e.producao_id
  FROM raw_data.equipe e
  WHERE LOWER(e.papel) IN ('director','composer','actor') -- ajuste os papéis alvo
)
SELECT ROUND(
  100.0 * (SELECT COUNT(*) FROM marcados)
  / NULLIF((SELECT COUNT(*) FROM raw_data.producao),0), 2
) AS percentual;
