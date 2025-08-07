-- Define o schema como padrão
SET search_path TO analytics;

-- Criação de usuários
CREATE USER analyst_movies WITH PASSWORD 'an@lyst#movies';
CREATE USER analyst_tv WITH PASSWORD 'an@lyst#tv';
CREATE USER analyst_games WITH PASSWORD 'an@lyst#games';
CREATE USER analyst_docs WITH PASSWORD 'an@lyst#docs';
CREATE USER analyst_all WITH PASSWORD 'an@lyst#all';
CREATE USER data_scientist WITH PASSWORD 'd@t4#scientist';

-- Concede a permissão USAGE no schema analytics a todos os novos usuários
GRANT USAGE ON SCHEMA analytics TO  analyst_movies,
									analyst_tv,
									analyst_games,
									analyst_docs,
									analyst_all,
									data_scientist;

-- Concessão de permissões específicas (princípio de menor privilégio)
GRANT SELECT ON TABLE analytics.movies TO analyst_movies;
GRANT SELECT ON TABLE analytics.tv_shows TO analyst_tv;
GRANT SELECT ON TABLE analytics.video_games TO analyst_games;
GRANT SELECT ON TABLE analytics.documentaries TO analyst_docs;

-- Concede permissão de SELECT em todas as tabelas no schema 'analytics' ao usuário 'analyst_all'.
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

-- Concede permissão de SELECT em todas as tabelas no schema 'analytics' ao usuário 'data_scientist'.
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO data_scientist;




/*
************ INICIO DOS TESTES ****************
*/
-- Inicia a transação com segurança para testes
BEGIN;

-- analyst_movies deve ter sucesso apenas em movies
SET ROLE analyst_movies;
SELECT * FROM analytics.movies;
-- Descomente a linha abaixo para verificar o erro de permissão
-- SELECT * FROM analytics.tv_shows;

-- analyst_tv deve ter sucesso apenas em tv_shows
SET ROLE analyst_tv;
SELECT * FROM analytics.tv_shows;

-- analyst_all deve ter sucesso em todas as tabelas
SET ROLE analyst_all;
SELECT * FROM analytics.movies;
SELECT * FROM analytics.tv_shows;
SELECT * FROM analytics.video_games;
SELECT * FROM analytics.documentaries;

-- data_scientist deve ter sucesso em leitura e escrita
SET ROLE data_scientist;
SELECT * FROM analytics.movies;
-- Esperado a falha do teste abaixo, pois não tem permissão para INSERT
INSERT INTO analytics.movies (producaoID, titulo, ano_producao, tipo_ID, nome_pessoa, papel)
VALUES (999999, 'Teste de Escrita', 2025, 'filme', 'Alexandre', 'Produtor');

-- Reverte a transação para desfazer as alterações dos testes
ROLLBACK;

-- Retorna ao usuário original
RESET ROLE;

/*
************ FIM DOS TESTES ****************
*/