-- Verificar duplicatas em equipe (equipe_duplicadas.json)
SELECT *
FROM raw_data.equipe
WHERE (id_producao, id_pessoa, papel) IN (
  (715197, 242878, 'Jack'),
  (715207, 192111, 'Narrator'),
  (715214, 111107, 'Party Goer'),
  (715218, 1031, 'Josh Stevens')
);

-- Verificar nulos em equipe (equipe_nulos.json)
SELECT *
FROM raw_data.equipe
WHERE papel IS NULL;

-- Verificar duplicatas em pessoa (pessoa_duplicadas.json)
SELECT *
FROM raw_data.pessoa
WHERE (id_pessoa, nome) IN (
  (86422, 'Brando, Marlon'),
  (86414, 'Brando Sr., Marlon'),
  (240796, 'Ford, Harrison'),
  (1240796, 'Snow, Rachel')
);

-- Verificar nulos em producao (producao_filtrado_nulos.json)
SELECT *
FROM raw_data.producao
WHERE titulo IS NULL;







