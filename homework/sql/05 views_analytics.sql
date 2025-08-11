/* -- 1. production_summary: Estatísticas resumidas por tipo de produção
CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT 
    CASE 
        WHEN tipo_id = '1' THEN 'Movies'
        WHEN tipo_id = '2' THEN 'TV Shows'
        WHEN tipo_id = '3' THEN 'Documentaries'
        WHEN tipo_id = '4' THEN 'Short Films'
        WHEN tipo_id = '5' THEN 'Music Videos'
        WHEN tipo_id = '6' THEN 'Video Games'
        WHEN tipo_id = '7' THEN 'Animations'
        ELSE 'Other'
    END AS production_type,
    COUNT(*) AS total_productions,
    MIN(ano_producao) AS earliest_year,
    MAX(ano_producao) AS latest_year
FROM raw_data.producao
GROUP BY tipo_id;

-- 2. top_actors_by_type: Atores mais ativos por tipo de produção
CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
SELECT 
    p.tipo_id,
    e.nome AS actor_name,
    COUNT(*) AS total_roles
FROM raw_data.producao p
JOIN raw_data.equipe e ON p.producaoid = e.producaoid
WHERE LOWER(e.papel) LIKE '%actor%' OR LOWER(e.papel) LIKE '%actress%'
GROUP BY p.tipo_id, e.nome
ORDER BY p.tipo_id, total_roles DESC;

-- 3. yearly_production_trends: Tendências de produção ao longo do tempo
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT 
    ano_producao,
    CASE 
        WHEN tipo_id = '1' THEN 'Movies'
        WHEN tipo_id = '2' THEN 'TV Shows'
        WHEN tipo_id = '3' THEN 'Documentaries'
        WHEN tipo_id = '4' THEN 'Short Films'
        WHEN tipo_id = '5' THEN 'Music Videos'
        WHEN tipo_id = '6' THEN 'Video Games'
        WHEN tipo_id = '7' THEN 'Animations'
        ELSE 'Other'
    END AS production_type,
    COUNT(*) AS productions_count
FROM raw_data.producao
GROUP BY ano_producao, tipo_id
ORDER BY ano_producao, production_type;

-- 4. crew_analysis: Análise de papéis e participação da equipe
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT 
    e.papel AS role,
    COUNT(DISTINCT e.nome) AS unique_people,
    COUNT(*) AS total_participations
FROM raw_data.equipe e
GROUP BY e.papel
ORDER BY total_participations DESC;
 */

CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT 'Movies' AS production_type, COUNT(*) AS total_productions, MIN(ano_producao) AS earliest_year, MAX(ano_producao) AS latest_year
FROM analytics.movies
UNION ALL
SELECT 'TV Shows', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.tv_shows
UNION ALL
SELECT 'Documentaries', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.documentaries
UNION ALL
SELECT 'Short Films', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.short_films
UNION ALL
SELECT 'Music Videos', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.music_videos
UNION ALL
SELECT 'Video Games', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.video_games
UNION ALL
SELECT 'Animations', COUNT(*), MIN(ano_producao), MAX(ano_producao) FROM analytics.animations;

CREATE OR REPLACE VIEW analytics.top_actors_by_type AS

SELECT
    'Movies' AS production_type,
    p.nome AS actor_name, -- CORREÇÃO: Buscando o nome da tabela de pessoas
    COUNT(*) AS total_roles
FROM
    analytics.movies m
JOIN
    raw_data.equipe e ON m.id_producao = e.id_producao
JOIN
    raw_data.pessoa p ON e.id_pessoa = p.id_pessoa -- CORREÇÃO: Nome da tabela atualizado
WHERE
    LOWER(e.papel) LIKE '%actor%' OR LOWER(e.papel) LIKE '%actress%'
GROUP BY
    p.nome -- CORREÇÃO: Agrupando pelo nome

UNION ALL

SELECT
    'TV Shows' AS production_type,
    p.nome AS actor_name, -- CORREÇÃO: Buscando o nome da tabela de pessoas
    COUNT(*) AS total_roles
FROM
    analytics.tv_shows t
JOIN
    raw_data.equipe e ON t.id_producao = e.id_producao -- ATENÇÃO: Verifique se a junção está correta. A chave em 'equipe' deve ser a mesma.
JOIN
    raw_data.pessoa p ON e.id_pessoa = p.id_pessoa -- CORREÇÃO: Nome da tabela atualizado
WHERE
    LOWER(e.papel) LIKE '%actor%' OR LOWER(e.papel) LIKE '%actress%'
GROUP BY
    p.nome; -- CORREÇÃO: Agrupando pelo nome

-- Repita o padrão para documentários, curtas, etc., sempre verificando as colunas de JOIN.


--YEARLY_PRODUCTION_TRENDS
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT ano_producao, 'Movies' AS production_type, COUNT(*) AS productions_count
FROM analytics.movies
GROUP BY ano_producao
UNION ALL
SELECT ano_producao, 'TV Shows', COUNT(*)
FROM analytics.tv_shows
GROUP BY ano_producao
UNION ALL
SELECT ano_producao, 'Documentaries', COUNT(*)
FROM analytics.documentaries
GROUP BY ano_producao;
-- Repete para os demais tipos...

--CREW_ANALYSIS
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT 
    LOWER(TRIM(e.papel)) AS papel,
    COUNT(*) AS total_participacoes
FROM raw_data.equipe e
WHERE e.papel IS NOT NULL AND LENGTH(e.papel) > 2
GROUP BY papel
ORDER BY total_participacoes DESC;


