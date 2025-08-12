/************************************************************************************
 * SCRIPT PARA A CRIAÇÃO DE VIEWS DE REPORTING (Camada Final)
 *
 * Objetivo: Criar views analíticas para responder a perguntas de negócio
 * e alimentar dashboards.
 ************************************************************************************/

-- Define o caminho de busca para simplificar os nomes de tabelas nas queries.
SET search_path TO analytics, trusted_data, public;

-- ===================================================================
-- VIEW 1: production_summary
-- Estatísticas resumidas por tipo de produção.
-- Fonte: trusted_data.vw_equipe_completa (contém todos os dados necessários já unidos)
-- ===================================================================
CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT
    tipo_producao,
    COUNT(DISTINCT "producaoID") AS total_de_producoes,
    MIN(NULLIF(ano_producao, 0)) AS primeiro_ano,
    MAX(NULLIF(ano_producao, 0)) AS ultimo_ano,
    COUNT(DISTINCT "pessoaID") AS total_de_pessoas_envolvidas
FROM
    trusted_data.vw_equipe_completa
GROUP BY
    tipo_producao
ORDER BY
    total_de_producoes DESC;

-- ===================================================================
-- VIEW 2: top_actors_by_type
-- Atores mais ativos (com mais produções) por tipo de produção.
-- Fonte: trusted_data.vw_equipe_completa (contém os papéis necessários para o filtro)
-- ===================================================================
CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
WITH actor_counts AS (
    SELECT
        e."pessoaID" AS ator_id,
        e.nome_pessoa AS nome,
        p.tipo_producao,
        COUNT(DISTINCT p."producaoID") AS numero_de_producoes
    FROM
        trusted_data.vw_equipe_completa AS e
    JOIN
        trusted_data.vw_producoes AS p ON e."producaoID" = p."producaoID"
    WHERE
        e.papel LIKE '%ator%' OR e.papel LIKE '%atriz%'
    GROUP BY
        e."pessoaID", e.nome_pessoa, p.tipo_producao
)
SELECT
    ator_id,
    nome,
    tipo_producao,
    numero_de_producoes,
    RANK() OVER(PARTITION BY tipo_producao ORDER BY numero_de_producoes DESC, nome ASC) AS ranking
FROM
    actor_counts;
-- ===================================================================
-- VIEW 3: yearly_production_trends
-- Contagem de produções por ano e por tipo, para ver tendências.
-- Fonte: Tabelas da camada Gold (unidas via CTE).
-- ===================================================================
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
WITH all_productions AS (
    SELECT id, ano, 'Filme' AS tipo_producao FROM analytics.movies
    UNION ALL
    SELECT id, ano, 'Série de TV' AS tipo_producao FROM analytics.tv_shows
    UNION ALL
    SELECT id, ano, 'Documentário' AS tipo_producao FROM analytics.documentaries
    UNION ALL
    SELECT id, ano, 'Videogame' AS tipo_producao FROM analytics.video_games
    UNION ALL
    SELECT id, ano, 'Curta-metragem' AS tipo_producao FROM analytics.short_films
    UNION ALL
    SELECT id, ano, 'Produção Teatral' AS tipo_producao FROM analytics.theater_productions
    UNION ALL
    SELECT id, ano, 'Filmes Adultos' AS tipo_producao FROM analytics.adult_films
    UNION ALL
    SELECT id, ano, 'Não categorizado' AS tipo_producao FROM analytics.uncategorized
)
SELECT
    ano,
    tipo_producao,
    COUNT(id) AS total_de_producoes
FROM
    all_productions
WHERE
    ano > 1900 AND ano <= EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    ano, tipo_producao
ORDER BY
    ano, tipo_producao;

-- ===================================================================
-- VIEW 4: crew_analysis
-- Análise de quantos papéis existem por tipo de produção e quantas pessoas únicas os desempenham.
-- Fonte: trusted_data.vw_equipe_completa (único local com a informação de papéis)
-- ===================================================================
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT 
	tipo_producao,
	papel,
	COUNT (DISTINCT "pessoaID") AS total_pessoa_por_papel
FROM 
    trusted_data.vw_equipe_completa
GROUP BY 
    papel, tipo_producao
ORDER BY 
    tipo_producao , papel ASC;

-- ===================================================================
-- FIM DO SCRIPT
-- Suas views analíticas estão criadas e prontas para uso.
-- ===================================================================