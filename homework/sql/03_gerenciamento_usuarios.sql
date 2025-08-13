-- Define o schema como padrão
SET search_path TO analytics;


-- Criação de usuarios
CREATE USER analyst_movies WITH PASSWORD 'an@lyst#movies';
CREATE USER analyst_tv WITH PASSWORD 'an@lyst#tv';
CREATE USER analyst_games WITH PASSWORD 'an@lyst#games';
CREATE USER analyst_docs WITH PASSWORD 'an@lyst#docs';
CREATE USER analyst_all WITH PASSWORD 'an@lyst#all';
CREATE USER data_scientist WITH PASSWORD 'd@t4#scientist';

-- CONCESSÃO DE PERMISSÕES
GRANT USAGE ON SCHEMA analytics TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;
GRANT SELECT ON TABLE analytics.movies TO analyst_movies;
GRANT SELECT ON TABLE analytics.tv_shows TO analyst_tv;
GRANT SELECT ON TABLE analytics.video_games TO analyst_games;
GRANT SELECT ON TABLE analytics.documentaries TO analyst_docs;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

-- Testes de acesso
-- Use o comando SET ROLE para simular o login de cada usuário e testar suas permissões.
-- Comente ou remova esta seção após a configuração inicial.


-- Primeiro, crie um "mock" de dados para testar.
-- ATENÇÃO: Se as tabelas já tiverem dados, você pode pular esta parte.
INSERT INTO analytics.movies (producaoID, titulo, ano_producao, tipo_ID, nome_pessoa, papel)
VALUES (1, 'Filme Exemplo 1', 2015, 'filme', 'João', 'Diretor');

INSERT INTO analytics.tv_shows (producaoID, titulo, ano_producao, tipo_ID, nome_pessoa, papel)
VALUES (2, 'Série Exemplo 1', 2021, 'serie', 'Maria', 'Atriz');

-- Inicia a transação para que os testes possam ser revertidos
BEGIN;

-- ---------------------------------------------------
-- Teste para ANALYST_MOVIES
-- ---------------------------------------------------
SET ROLE analyst_movies;
RAISE NOTICE '==> Testando analyst_movies...';

-- Tentativa de leitura na tabela 'movies' (deve ser bem-sucedida)
SELECT * FROM analytics.movies;

-- Tentativa de leitura em uma tabela proibida ('tv_shows') (deve falhar)
-- Descomente a linha abaixo para ver o erro de permissão
-- SELECT * FROM analytics.tv_shows;

-- ---------------------------------------------------
-- Teste para ANALYST_TV
-- ---------------------------------------------------
SET ROLE analyst_tv;
RAISE NOTICE '==> Testando analyst_tv...';

-- Tentativa de leitura na tabela 'tv_shows' (deve ser bem-sucedida)
SELECT * FROM analytics.tv_shows;

-- ---------------------------------------------------
-- Teste para ANALYST_ALL
-- ---------------------------------------------------
SET ROLE analyst_all;
RAISE NOTICE '==> Testando analyst_all...';

-- Tentativa de leitura em 'movies' (deve ser bem-sucedida)
SELECT * FROM analytics.movies;

-- Tentativa de leitura em 'tv_shows' (deve ser bem-sucedida)
SELECT * FROM analytics.tv_shows;

-- ---------------------------------------------------
-- Teste para DATA_SCIENTIST
-- ---------------------------------------------------
SET ROLE data_scientist;
RAISE NOTICE '==> Testando data_scientist...';

-- Tentativa de leitura em 'movies' (deve ser bem-sucedida)
SELECT * FROM analytics.movies;

-- Tentativa de escrita (INSERT) em 'movies' (deve ser bem-sucedida)
INSERT INTO analytics.movies (producaoID, titulo, ano_producao, tipo_ID, nome_pessoa, papel)
VALUES (3, 'Teste de Escrita', 2022, 'filme', 'José', 'Produtor');

-- Reverte a transação para desfazer as alterações dos testes
ROLLBACK;

-- Retorna ao usuário original (postgres, por exemplo)
RESET ROLE;

RAISE NOTICE 'Testes de permissões concluídos.';
