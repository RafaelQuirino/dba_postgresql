SELECT producao_tipo_id, titulo, ano_producao
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY producao_tipo_id ORDER BY RANDOM()) AS rn
    FROM raw_data.producao
    WHERE ano_producao IS NOT NULL
) sub
WHERE rn <= 30 and sub.ano_producao IS NOT NULL
ORDER BY producao_tipo_id, rn;