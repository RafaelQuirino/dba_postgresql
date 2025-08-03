-- 3) Ingestão de dados
-- python ingestao_dados.py /app/pessoacopy.txt pessoa '(pessoaID,nome)' 'int,string'
-- python ingestao_dados.py /app/producao.txt producao '(producaoID,titulo,ano_producao,tipo_ID)' 'int,string,int,int'
-- python ingestao_dados.py /app/equipe.txt equipe '(pessoaID,producaoID,papel)' 'int,int,string'


INSERT INTO analytics.movies (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 1;


INSERT INTO analytics.tv_shows (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 7;


INSERT INTO analytics.video_games (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 6;


INSERT INTO analytics.documentaries (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 4;


INSERT INTO analytics.short_films (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 3;


INSERT INTO analytics.music_videos (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 5;


INSERT INTO analytics.animations (titulo, ano_producao, nome_pessoa, papel)
SELECT
    prod.titulo,
    prod.ano_producao,
    ps.nome,
    e.papel
FROM
    raw_data.producao AS prod
JOIN
    raw_data.equipe AS e ON prod.producaoID = e.producaoID
JOIN
    raw_data.pessoa AS ps ON ps.pessoaID = e.pessoaID
WHERE
    prod.tipo_ID = 2;


