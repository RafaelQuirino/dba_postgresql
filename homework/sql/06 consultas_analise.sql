--Qual tipo de produção tem mais produções?
SELECT production_type, total_productions
FROM analytics.production_summary
ORDER BY total_productions DESC
LIMIT 1;

-- Quais são os 10 atores mais ativos em todos os tipos de produção?
SELECT actor_name, SUM(total_roles) AS total_roles_all_types
FROM analytics.top_actors_by_type
GROUP BY actor_name
ORDER BY total_roles_all_types DESC
LIMIT 10;

--Como o número de produções mudou nos últimos 50 anos?
SELECT ano_producao, SUM(productions_count) AS total_productions
FROM analytics.yearly_production_trends
WHERE ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
GROUP BY ano_producao
ORDER BY ano_producao;

--Quais anos tiveram a maior produção?
SELECT ano_producao, SUM(productions_count) AS total_productions
FROM analytics.yearly_production_trends
GROUP BY ano_producao
ORDER BY total_productions DESC
LIMIT 5;

--Qual porcentagem de produções tem membros da equipe com papéis específicos?

WITH total AS (
    SELECT COUNT(DISTINCT id_producao) AS total_productions
    FROM raw_data.producao
),
with_role AS (
    SELECT COUNT(DISTINCT p.id_producao) AS productions_with_role
    FROM raw_data.producao p
    JOIN raw_data.equipe e ON p.id_producao = e.id_producao
    WHERE LOWER(e.papel) IN ('director', 'writer') --exemplo com director or writer
)
SELECT 
    productions_with_role,
    total_productions,
    ROUND((productions_with_role::NUMERIC / total_productions) * 100, 2) AS percentage
FROM total, with_role;



