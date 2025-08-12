/************************************************************************************
 * SCRIPT PARA CRIAÇÃO DE VIEWS DE RESPOSTAS DE NEGÓCIO (KPIs)
 *
 * Objetivo: Criar views que respondem diretamente a questões de negócio específicas,
 * servindo como a camada final para relatórios e dashboards.
 ************************************************************************************/

-- Define o caminho de busca para simplificar as queries.
SET search_path TO analytics, trusted_data, public;

-- ===================================================================
-- 1. View para a pergunta: "Qual tipo de produção tem mais produções?"
-- ===================================================================
CREATE OR REPLACE VIEW analytics.vw_top_production_type AS
SELECT
    tipo_producao,
    total_de_producoes
FROM
    analytics.production_summary
ORDER BY
    total_de_producoes DESC
LIMIT 1;

-- ===================================================================
-- 2. View para a pergunta: "Quais são os 10 atores mais ativos em todos os tipos de produção?"
-- ===================================================================
CREATE OR REPLACE VIEW analytics.vw_top_10_actors_global AS
SELECT 
	nome, 
	tipo_producao,
	numero_de_producoes,
	ranking
FROM 
	analytics.top_actors_by_type
WHERE 
	ranking <= 10;

-- ===================================================================
-- 3. View para a pergunta: "Como o número de produções mudou nos últimos 50 anos?"
-- ===================================================================
CREATE OR REPLACE VIEW analytics.vw_production_trend_last_50_years AS
SELECT 	
	* 
FROM 
	analytics.yearly_production_trends
WHERE 
    ano >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
ORDER BY 
    ano, total_de_producoes DESC;

-- ===================================================================
-- 4. View para a pergunta: "Quais anos tiveram a maior produção?"
-- ===================================================================
CREATE OR REPLACE VIEW analytics.vw_top_10_production_years AS
SELECT
    ano,
    SUM(total_de_producoes) AS total_anual
FROM
    analytics.yearly_production_trends
GROUP BY
    ano
ORDER BY
    total_anual DESC
LIMIT 10;

-- ===================================================================
-- 5. View para a pergunta: "Qual porcentagem de produções tem membros da equipe com papéis específicos?"
-- ===================================================================
CREATE OR REPLACE VIEW analytics.vw_role_participation_percentage AS
WITH
total_producoes_geral AS (
    SELECT COUNT(DISTINCT "producaoID") AS total
    FROM trusted_data.vw_producoes
),
producoes_por_papel AS (
    SELECT
        papel,
        COUNT(DISTINCT "producaoID") AS producoes_com_o_papel
    FROM
        trusted_data.vw_equipe_completa
    WHERE
        "pessoaID" IS NOT NULL
    GROUP BY
        papel
)
SELECT
    p.papel,
    p.producoes_com_o_papel,
    t.total AS total_geral_de_producoes,
    ROUND((p.producoes_com_o_papel::DECIMAL / t.total) * 100, 2) AS porcentagem_de_participacao
FROM
    producoes_por_papel AS p,
    total_producoes_geral AS t
ORDER BY
    porcentagem_de_participacao DESC;

-- ===================================================================
-- FIM DO SCRIPT
-- Suas views de negócio estão prontas para consulta.
-- ===================================================================