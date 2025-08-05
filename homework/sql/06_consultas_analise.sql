

-- Fase 4 - Passo 7


'''
1. **Qual tipo de produção tem mais produções?**
2. **Quais são os 10 atores mais ativos em todos os tipos de produção?**
3. **Como o número de produções mudou nos últimos 50 anos?**
4. **Quais anos tiveram a maior produção?**
5. **Qual porcentagem de produções tem membros da equipe com papéis específicos?**
'''

-- 1. **Qual tipo de produção tem mais produções?**
SELECT 
	ps.tipo_id
	ps.total_producoes
FROM
	analytics.production_summary as ps
ORDER BY
	ps.total_producoes DESC
LIMIT 1;

-- 2. **Quais são os 10 atores mais ativos em todos os tipos de produção?**
SELECT
	ps.nome,
	COUNT(prod.titulo) AS total_participacao
FROM raw_data.producao AS prod
JOIN raw_data.equipe AS e ON e.producaoid = prod.producaoid
JOIN raw_data.pessoa AS ps ON ps.pessoaid = e.pessoaid
GROUP BY ps.nome
ORDER BY 2 DESC
LIMIT 10;

-- 3. **Como o número de produções mudou nos últimos 50 anos?**
SELECT
    COUNT(DISTINCT titulo) AS total_producoes,
    ano_producao
FROM raw_data.producao
WHERE ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
GROUP BY ano_producao
ORDER BY ano_producao DESC;

-- 4. **Quais anos tiveram a maior produção?**
SELECT
    COUNT(DISTINCT titulo) AS total_producoes,
    ano_producao
FROM raw_data.producao
WHERE ano_producao <> 0
GROUP BY ano_producao
ORDER BY total_producoes DESC
LIMIT 5;


-- 5. **Qual porcentagem de produções tem membros da equipe com papéis específicos?**
WITH producoes_sem_papeis_especificos AS(
	SELECT 
		COUNT(*) AS qtd
	FROM raw_data.producao AS prod
	JOIN raw_data.equipe AS e ON e.producaoid = prod.producaoid
	WHERE e.papel <> 'null'
),
total_producoes AS(
	SELECT 
		COUNT(*) AS qtd
	FROM raw_data.producao AS prod
	JOIN raw_data.equipe AS e ON e.producaoid = prod.producaoid
)
SELECT 
	ROUND((ppe.qtd::NUMERIC / tp.qtd::NUMERIC) * 100, 2) AS porcentagem_ppe
FROM
	producoes_sem_papeis_especificos AS ppe,
	total_producoes AS tp;