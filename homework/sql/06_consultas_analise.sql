-- Tipo de produção com mais registros
SELECT tipo_id, COUNT(*) AS total
FROM raw_data.producao
GROUP BY tipo_id
ORDER BY total DESC
LIMIT 1;

-- Top 10 nomes com mais participações em qualquer tipo
SELECT pe.nome, COUNT(*) AS participacoes
FROM raw_data.equipe e
JOIN raw_data.pessoa pe ON pe.id_pessoa = e.id_pessoa
GROUP BY pe.nome
ORDER BY participacoes DESC
LIMIT 10;

-- Evolução das produções por ano (últimos 50 anos)
SELECT ano, COUNT(*) AS total
FROM raw_data.producao
WHERE ano >= (EXTRACT(YEAR FROM CURRENT_DATE) - 50)
GROUP BY ano
ORDER BY ano;

-- Anos com mais produções registradas
SELECT ano, COUNT(*) AS total
FROM raw_data.producao
GROUP BY ano
ORDER BY total DESC
LIMIT 10;

-- Porcentagem de produções com ao menos um "Diretor"
WITH producoes_com_diretor AS (
    SELECT DISTINCT id_producao
    FROM raw_data.equipe
    WHERE LOWER(papel) LIKE '%director%' OR LOWER(papel) LIKE '%diretor%'
)
SELECT 
    (SELECT COUNT(*) FROM producoes_com_diretor)::DECIMAL 
    / (SELECT COUNT(*) FROM raw_data.producao) * 100 AS percentual_com_diretor;
