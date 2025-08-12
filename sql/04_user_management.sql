-- Fase 3: Gerenciamento de Usuários e Controle de Acesso (Versão Final Idempotente)

-- PASSO 1: LIMPEZA COMPLETA DOS USUÁRIOS
-- Executa a limpeza em um bloco para ignorar erros caso um usuário não exista
DO $$
BEGIN
    -- Reatribui a propriedade de objetos e remove os usuários
    REASSIGN OWNED BY analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist TO postgres;
    DROP ROLE IF EXISTS analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;
EXCEPTION
    WHEN UNDEFINED_OBJECT THEN
        -- Ignora o erro se um dos roles não existir
        RAISE NOTICE 'Um ou mais roles não existiam, continuando a limpeza.';
END;
$$;


-- PASSO 2: CRIAR TODOS OS USUÁRIOS DO ZERO
CREATE ROLE analyst_movies LOGIN PASSWORD 'senha_forte_movies';
CREATE ROLE analyst_tv LOGIN PASSWORD 'senha_forte_tv';
CREATE ROLE analyst_games LOGIN PASSWORD 'senha_forte_games';
CREATE ROLE analyst_docs LOGIN PASSWORD 'senha_forte_docs';
CREATE ROLE analyst_all LOGIN PASSWORD 'senha_forte_all';
CREATE ROLE data_scientist LOGIN PASSWORD 'senha_forte_ds';


-- PASSO 3: CONCEDER PERMISSÕES
-- Acesso aos schemas
GRANT USAGE ON SCHEMA analytics, raw_data TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;

-- Acesso de leitura às tabelas de elenco
GRANT SELECT ON TABLE raw_data.pessoa, raw_data.equipe TO analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist;

-- Permissões específicas
GRANT SELECT ON TABLE analytics.movies TO analyst_movies;
GRANT SELECT ON TABLE analytics.tv_shows TO analyst_tv;
GRANT SELECT ON TABLE analytics.video_games TO analyst_games;
GRANT SELECT ON TABLE analytics.documentaries TO analyst_docs;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO data_scientist;
GRANT CREATE ON SCHEMA analytics TO data_scientist;


-- PASSO 4: PERMISSÃO DE PERSONIFICAÇÃO PARA A API
GRANT analyst_movies, analyst_tv, analyst_games, analyst_docs, analyst_all, data_scientist TO postgres;