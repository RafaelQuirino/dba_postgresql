-- Define o schema como padrão
SET search_path TO analytics;

/* production_summary
 Consulta resumida da quantidade de produções e a média do ano de produção por tipo 
*/
CREATE VIEW production_summary AS
SELECT
    p.tipo_ID,
    COUNT(p.producaoID) AS total_producoes,
    MIN(p.ano_producao) AS ano_minimo,
    MAX(p.ano_producao) AS ano_maximo,
    AVG(p.ano_producao) AS media_ano_producao
FROM
    raw_data.producao p
GROUP BY
    p.tipo_ID
ORDER BY
    total_producoes DESC;

/*top_actors_by_type
 Atores mais ativos em cada tipo de produção
*/
CREATE OR REPLACE VIEW top_actors_by_type AS
SELECT
    p.tipo_ID,
    e.papel,
    pe.nome AS nome_ator,
    COUNT(e.producaoID) AS total_participacoes
FROM
    raw_data.equipe e
JOIN
    raw_data.pessoa pe ON e.pessoaID = pe.pessoaID
JOIN
    raw_data.producao p ON e.producaoID = p.producaoID
WHERE
    e.papel IN ('Ator', 'Atriz')
GROUP BY
    p.tipo_ID,
    e.papel,
    pe.nome
ORDER BY
    p.tipo_ID,
    total_participacoes DESC;

/* yearly_production_trends
 Tendência de produção ao longo dos anos, contando o número de produções por ano e tipo
*/
CREATE OR REPLACE VIEW yearly_production_trends AS
SELECT
    p.ano_producao,
    p.tipo_ID,
    COUNT(p.producaoID) AS total_producoes
FROM
    raw_data.producao p
GROUP BY
    p.ano_producao,
    p.tipo_ID
ORDER BY
    p.ano_producao,
    p.tipo_ID;

/* crew_analysis
   Análise dos papéis da equipe, contando quantas pessoas participaram e o total de participações por papel
*/
CREATE OR REPLACE VIEW crew_analysis AS
SELECT
    e.papel,
    COUNT(DISTINCT e.pessoaID) AS total_pessoas_no_papel,
    COUNT(e.producaoID) AS total_participacoes
FROM
    raw_data.equipe e
GROUP BY
    e.papel
ORDER BY
    total_participacoes DESC;