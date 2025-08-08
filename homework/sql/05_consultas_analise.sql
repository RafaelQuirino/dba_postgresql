-- Tipo de produção que tem mais registros
SELECT tipo_id, COUNT(*) AS total
FROM raw_data.producao
GROUP BY tipo_id
ORDER BY total DESC
LIMIT 1;

-- Top 10 atores com mais participações para cada tipo de produção
SELECT pe.nome, COUNT(*) AS participacoes
FROM raw_data.equipe e
JOIN raw_data.pessoa pe ON pe.pessoaID = e.pessoaID
GROUP BY pe.nome
ORDER BY participacoes DESC
LIMIT 10;

-- Evolução do número de produções nos últimos 50 anos
SELECT ano_producao, COUNT(*) AS total
FROM raw_data.producao
WHERE ano_producao >= (EXTRACT(YEAR FROM CURRENT_DATE) - 50)
GROUP BY ano_producao
ORDER BY ano_producao;

-- Anos com a maior quantidade de produções
SELECT ano_producao, COUNT(*) AS total
FROM raw_data.producao
GROUP BY ano_producao
ORDER BY total DESC
LIMIT 10;

-- Porcentagem de produções com pelo menos um "Ator"
WITH producoes_com_ator AS (
    SELECT DISTINCT producaoID
    FROM raw_data.equipe
    WHERE LOWER(papel) LIKE '%actor%' OR LOWER(papel) LIKE '%actor%'
)
SELECT 
    (SELECT COUNT(*) FROM producoes_com_ator)::DECIMAL 
    / (SELECT COUNT(*) FROM raw_data.producao) * 100 AS percentual_com_ator;