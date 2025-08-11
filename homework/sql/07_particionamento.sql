-- para descobrir quantas pessoas têm por primeira letra do nome
SELECT
  UPPER(LEFT(nome, 1)) AS primeira_letra,
  COUNT(*) AS total_pessoas
FROM raw_data.pessoa
GROUP BY UPPER(LEFT(nome, 1))
ORDER BY primeira_letra;

