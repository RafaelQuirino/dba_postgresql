-- Teste 1: IDs duplicados em pessoa
SELECT id_pessoa, COUNT(*) 
FROM raw_data.pessoa 
GROUP BY id_pessoa 
HAVING COUNT(*) > 1;

-- Teste 2: IDs duplicados em producao
SELECT id_producao, COUNT(*) 
FROM raw_data.producao 
GROUP BY id_producao 
HAVING COUNT(*) > 1;

-- Teste 3: IDs de equipe que não existem em pessoa
SELECT DISTINCT e.id_pessoa 
FROM raw_data.equipe e
LEFT JOIN raw_data.pessoa p ON e.id_pessoa = p.id_pessoa
WHERE p.id_pessoa IS NULL;

-- Teste 4: IDs de equipe que não existem em producao
SELECT DISTINCT e.id_producao 
FROM raw_data.equipe e
LEFT JOIN raw_data.producao p ON e.id_producao = p.id_producao
WHERE p.id_producao IS NULL;

-- Teste 5: Registros com ano inválido (menor que 1800 ou maior que 2100)
SELECT * 
FROM raw_data.producao 
WHERE ano < 1800 OR ano > 2100;

-- Teste 6: tipo_id nulo ou inválido
SELECT * 
FROM raw_data.producao 
WHERE tipo_id IS NULL OR tipo_id = '';
