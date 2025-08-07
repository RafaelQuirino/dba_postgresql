-- production_summary – total de produções por tipo
CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT 
    tipo_id,
    COUNT(*) AS total_producoes,
    MIN(ano) AS ano_mais_antigo,
    MAX(ano) AS ano_mais_recente
FROM raw_data.producao
GROUP BY tipo_id
ORDER BY total_producoes DESC;

-- top_actors_by_type – atores mais ativos por tipo de produção
CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
SELECT 
    p.tipo_id,
    pe.nome,
    COUNT(*) AS participacoes
FROM raw_data.equipe e
JOIN raw_data.pessoa pe ON pe.id_pessoa = e.id_pessoa
JOIN raw_data.producao p ON p.id_producao = e.id_producao
GROUP BY p.tipo_id, pe.nome
HAVING COUNT(*) >= 10  -- ajustável
ORDER BY p.tipo_id, participacoes DESC;

-- yearly_production_trends – evolução por ano
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT 
    ano,
    COUNT(*) AS total_producoes
FROM raw_data.producao
GROUP BY ano
ORDER BY ano;

-- crew_analysis – número de participações por papel
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT 
    LOWER(TRIM(e.papel)) AS papel_normalizado,
    COUNT(*) AS total_participacoes
FROM raw_data.equipe e
WHERE e.papel IS NOT NULL AND LENGTH(e.papel) > 2
GROUP BY papel_normalizado
ORDER BY total_participacoes DESC;

-- Validar views
SELECT * FROM analytics.production_summary LIMIT 10;
SELECT * FROM analytics.top_actors_by_type LIMIT 10;
SELECT * FROM analytics.yearly_production_trends LIMIT 10;
SELECT * FROM analytics.crew_analysis LIMIT 10;
