-- Passo 6


-- 1. **`production_summary`** - Estatísticas resumidas por tipo de produção
CREATE VIEW analytics.production_summary AS
SELECT
    prod.tipo_id,
    COUNT(DISTINCT prod.titulo) AS total_producoes,
    COUNT(DISTINCT ps.nome) AS total_atores_unicos,
    COUNT(DISTINCT e.papel) AS total_papeis_unicos_por_tipo
FROM raw_data.producao AS prod
JOIN raw_data.equipe AS e ON prod.producaoid = e.producaoid
JOIN raw_data.pessoa AS ps ON e.pessoaid = ps.pessoaid
GROUP BY
    prod.tipo_id
ORDER BY
    prod.tipo_id;


-- 2. **`top_actors_by_type`** - Atores mais ativos por tipo de produção
CREATE VIEW analytics.top_actors_by_type AS
WITH AtorContagemPorTipo AS (
	SELECT
		prod.tipo_id,
		ps.nome,
		COUNT(*) AS contagem_aparicoes,
		ROW_NUMBER() OVER (PARTITION BY prod.tipo_id ORDER BY COUNT(*) DESC) AS rk
	FROM raw_data.producao AS prod
	JOIN raw_data.equipe AS e ON prod.producaoid = e.producaoid
	JOIN raw_data.pessoa AS ps ON e.pessoaid = ps.pessoaid
	WHERE
		ps.nome IS NOT NULL
	GROUP BY
		prod.tipo_id,
		ps.nome
	ORDER BY 3 DESC
)
SELECT 
	tipo_id,
	nome,
	contagem_aparicoes
FROM 
	AtorContagemPorTipo
WHERE 
	rk = 1
ORDER BY 1;