-- 05_consultas_analise.sql
-- Perguntas analíticas (ignorando year = 0)

-- 1) Qual tipo de produção tem mais produções?
SELECT production_type, COUNT(*) AS total
FROM analytics.productions_unified
WHERE year > 0
GROUP BY production_type
ORDER BY total DESC, production_type ASC
LIMIT 1;

-- alternativa: ranking completo
SELECT production_type, COUNT(*) AS total,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM analytics.productions_unified
WHERE year > 0
GROUP BY production_type;

-- 2) Quais são os 10 atores (pessoas) mais ativos em todos os tipos?
SELECT p.person_id, p.name, COUNT(*) AS total_appearances
FROM analytics.crew c
JOIN analytics.persons p ON p.person_id = c.person_id
-- opcional: filtrar por produções com year>0
JOIN analytics.productions_unified u
  ON u.production_type = c.production_type AND u.production_id = c.production_id
WHERE u.year > 0
GROUP BY p.person_id, p.name
ORDER BY total_appearances DESC, p.name ASC
LIMIT 10;

-- 3) Como o número de produções mudou nos últimos 50 anos?
-- Considera os 50 anos mais recentes presentes nos dados (ignorando 0)
WITH yrs AS (
  SELECT DISTINCT year FROM analytics.productions_unified WHERE year > 0
),
lim AS (
  SELECT MAX(year) AS maxy FROM yrs
)
SELECT u.year, COUNT(*) AS total
FROM analytics.productions_unified u, lim
WHERE u.year > 0
  AND u.year BETWEEN (lim.maxy - 49) AND lim.maxy
GROUP BY u.year
ORDER BY u.year;

-- 4) Quais anos tiveram a maior produção?
WITH yearly AS (
  SELECT year, COUNT(*) AS total
  FROM analytics.productions_unified
  WHERE year > 0
  GROUP BY year
)
SELECT year, total
FROM yearly
WHERE total = (SELECT MAX(total) FROM yearly)
ORDER BY year;

-- 5) Qual porcentagem de produções tem membros da equipe com papéis específicos?
-- Exemplo para um conjunto de papéis
-- Troque a lista ('Director','Actor') conforme necessário
WITH all_titles AS (
  SELECT production_type, production_id
  FROM analytics.productions_unified
  WHERE year > 0
),
flagged AS (
  SELECT DISTINCT c.production_type, c.production_id
  FROM analytics.crew c
  WHERE c.job IN ('Director','Actor') -- ajuste aqui
)
SELECT
  (SELECT COUNT(*) FROM flagged) * 100.0 / NULLIF((SELECT COUNT(*) FROM all_titles),0) AS percentage_with_specified_roles;