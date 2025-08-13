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
GRANT USAGE ON SCHEMA analytics TO 
    analyst_movies,
    analyst_tv,
    analyst_games,
    analyst_docs,
    analyst_all,
    data_scientist;

-- Concessão de permissões específicas (princípio do menor privilégio)
GRANT SELECT ON TABLE analytics.movies TO analyst_movies;
GRANT SELECT ON TABLE analytics.tv_shows TO analyst_tv;
GRANT SELECT ON TABLE analytics.video_games TO analyst_games;
GRANT SELECT ON TABLE analytics.documentaries TO analyst_docs;

-- analyst_all tem permissão de leitura em todas as tabelas do schema analytics
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

-- data_scientist tem permissão total (leitura e escrita) em todas as tabelas do schema analytics
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;

-- Para garantir que futuras tabelas criadas também terão permissões corretas:
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT SELECT ON TABLES TO analyst_all;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_scientist;


-- *************** INÍCIO DOS TESTES ****************

BEGIN;

-- analyst_movies deve ter sucesso apenas em movies
SET ROLE analyst_movies;
SELECT * FROM analytics.movies;
-- SELECT * FROM analytics.tv_shows; -- Esperado erro de permissão

-- analyst_tv deve ter sucesso apenas em tv_shows
SET ROLE analyst_tv;
SELECT * FROM analytics.tv_shows;

-- analyst_all deve ter sucesso em todas as tabelas (exemplo com 2 tabelas)
SET ROLE analyst_all;
SELECT * FROM analytics.movies;
SELECT * FROM analytics.tv_shows;

-- data_scientist deve ter sucesso em leitura e escrita
SET ROLE data_scientist;
SELECT * FROM analytics.movies;

-- Teste de INSERT válido (apenas colunas existentes)
INSERT INTO analytics.movies (producaoID, titulo, ano_producao, tipo_ID)
VALUES (111111, 'ESSE USUÁRIO DEVE PERMITIR ESCRITA?', 2025, '1');

-- Reverte a transação para desfazer as alterações dos testes
ROLLBACK;

RESET ROLE;

-- *************** FIM DOS TESTES ****************
