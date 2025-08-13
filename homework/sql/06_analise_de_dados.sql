--1. Qual tipo de produção tem mais produções?
SELECT
    tipo_ID,
    COUNT(*) AS total_producoes
FROM
    raw_data.producao
GROUP BY
    tipo_ID
ORDER BY
    total_producoes DESC
LIMIT 1;

--2. Quais são os 10 atores mais ativos em todos os tipos de produção?
SELECT
    pe.nome AS nome_ator,
    COUNT(e.producaoID) AS total_participacoes
FROM
    raw_data.equipe e
JOIN
    raw_data.pessoa pe ON e.pessoaID = pe.pessoaID
WHERE
    e.papel IN ('Ator', 'Atriz')
GROUP BY
    pe.nome
ORDER BY
    total_participacoes DESC
LIMIT 10;

--3. Como o número de produções mudou nos últimos 50 anos?
SELECT
    ano_producao,
    COUNT(producaoID) AS total_producoes
FROM
    raw_data.producao
WHERE
    ano_producao >= EXTRACT(YEAR FROM CURRENT_DATE) - 50
GROUP BY
    ano_producao
ORDER BY
    ano_producao;

--4. Quais anos tiveram a maior produção?
SELECT
    ano_producao,
    COUNT(producaoID) AS total_producoes
FROM
    raw_data.producao
GROUP BY
    ano_producao
ORDER BY
    total_producoes DESC
LIMIT 5;

--5. Qual porcentagem de produções tem membros da equipe com papéis específicos?
SELECT 
    ROUND(
        SUM(CASE WHEN e.papel <> 'null' THEN 1 ELSE 0 END)::NUMERIC / 
        COUNT(*)::NUMERIC * 100, 2
    ) AS porcentagem_ppe
FROM raw_data.producao p
JOIN raw_data.equipe e ON e.producaoid = p.producaoid;
