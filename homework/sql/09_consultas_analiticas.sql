-- =============================
-- Fase 4: Analytics e Relatórios
-- Passo 7: Consultas de Análise de Dados
-- =============================

-- 1. Qual tipo de produção tem mais produções?
SELECT tipo, total
FROM analytics.production_summary
ORDER BY total DESC
LIMIT 1;


-- 2. Quais são os 10 atores mais ativos em todos os tipos de produção?
SELECT
  p.pessoa_id,
  p.nome,
  eq.total_producoes
FROM (
  SELECT pessoa_id, COUNT(*) AS total_producoes
  FROM analytics.equipe
  GROUP BY pessoa_id
  ORDER BY COUNT(*) DESC
  LIMIT 10
) eq
JOIN analytics.pessoa p ON p.pessoa_id = eq.pessoa_id
ORDER BY eq.total_producoes DESC;

-- 3. Como o número de produções mudou nos últimos 50 anos?
SELECT ano_producao, SUM(total) AS total_producoes
FROM analytics.yearly_production_trends
WHERE ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
GROUP BY ano_producao
ORDER BY ano_producao;

-- 4. Quais anos tiveram a maior produção?
SELECT ano_producao, SUM(total) AS total_producoes
FROM analytics.yearly_production_trends
GROUP BY ano_producao
ORDER BY total_producoes DESC
LIMIT 10;

-- 5. Qual porcentagem de produções tem membros da equipe com papéis específicos?
-- Exemplo: porcentagem de produções com pelo menos um 'Diretor'
SELECT
  COUNT(DISTINCT e.producao_id) * 100.0 / (SELECT COUNT(*) FROM raw_data.producao) AS perc_com_diretor
FROM analytics.equipe e
WHERE e.papel ILIKE '%diretor%';