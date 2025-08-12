/************************************************************************************
 * SCRIPT DE GERENCIAMENTO DE ACESSO (RBAC - Role-Based Access Control)
 *
 * Versão: Final (À Prova de Balas - Idempotente)
 * Objetivo: Criar uma estrutura segura de permissões que funciona na primeira
 * execução e em todas as subsequentes.
 ************************************************************************************/

--==================================================================================
-- SEÇÃO DE LIMPEZA GERAL (SETUP)
--==================================================================================

-- 1. Apaga os usuários finais (que dependem dos grupos)
--    DROP ROLE IF EXISTS é seguro e não causa erros.
DROP ROLE IF EXISTS analyst_all;
DROP ROLE IF EXISTS data_scientist;
DROP ROLE IF EXISTS analyst_movies;
DROP ROLE IF EXISTS analyst_tv;
DROP ROLE IF EXISTS analyst_games;
DROP ROLE IF EXISTS analyst_docs;
DROP ROLE IF EXISTS analyst_shorts;
DROP ROLE IF EXISTS analyst_theater;
DROP ROLE IF EXISTS analyst_adults;
DROP ROLE IF EXISTS analyst_uncategorized;

-- 2. Revoga as permissões dos grupos (usando DO blocks para evitar erros)
DO $$ BEGIN IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'analyst_base') THEN
    REVOKE ALL ON DATABASE cinetech_productions FROM analyst_base;
    REVOKE ALL ON SCHEMA trusted_data, analytics FROM analyst_base;
END IF; END $$;

DO $$ BEGIN IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'all_analytics_reader') THEN
    REVOKE ALL ON ALL TABLES IN SCHEMA trusted_data FROM all_analytics_reader;
    REVOKE ALL ON ALL TABLES IN SCHEMA analytics FROM all_analytics_reader;
END IF; END $$;

DO $$ BEGIN IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'data_science_full_access') THEN
    REVOKE ALL ON SCHEMA analytics FROM data_science_full_access;
    REVOKE ALL ON ALL TABLES IN SCHEMA analytics FROM data_science_full_access;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA analytics FROM data_science_full_access;
END IF; END $$;

-- 3. Apaga os grupos de permissão (agora livres de quaisquer dependências)
DROP ROLE IF EXISTS analyst_base;
DROP ROLE IF EXISTS all_analytics_reader;
DROP ROLE IF EXISTS data_science_full_access;
DROP ROLE IF EXISTS movies_reader;
DROP ROLE IF EXISTS tv_shows_reader;
DROP ROLE IF EXISTS games_reader;
DROP ROLE IF EXISTS docs_reader;
DROP ROLE IF EXISTS short_films_reader;
DROP ROLE IF EXISTS theater_prod_reader;
DROP ROLE IF EXISTS adult_films_reader;
DROP ROLE IF EXISTS uncategorized_reader;

--==================================================================================
-- SEÇÃO A: CRIAÇÃO DAS ROLES DE GRUPO ("CRACHÁS DE ACESSO")
--==================================================================================
CREATE ROLE analyst_base;
CREATE ROLE all_analytics_reader;
CREATE ROLE data_science_full_access;
CREATE ROLE movies_reader;
CREATE ROLE tv_shows_reader;
CREATE ROLE games_reader;
CREATE ROLE docs_reader;
CREATE ROLE short_films_reader;
CREATE ROLE theater_prod_reader;
CREATE ROLE adult_films_reader;
CREATE ROLE uncategorized_reader;

--==================================================================================
-- SEÇÃO B: CONCESSÃO DE PERMISSÕES (GRANTS) PARA AS ROLES DE GRUPO
--==================================================================================
GRANT CONNECT ON DATABASE cinetech_productions TO analyst_base;
GRANT USAGE ON SCHEMA trusted_data, analytics TO analyst_base;

GRANT SELECT ON TABLE analytics.movies TO movies_reader;
GRANT SELECT ON TABLE analytics.tv_shows TO tv_shows_reader;
GRANT SELECT ON TABLE analytics.video_games TO games_reader;
GRANT SELECT ON TABLE analytics.documentaries TO docs_reader;
GRANT SELECT ON TABLE analytics.short_films TO short_films_reader;
GRANT SELECT ON TABLE analytics.theater_productions TO theater_prod_reader;
GRANT SELECT ON TABLE analytics.adult_films TO adult_films_reader;
GRANT SELECT ON TABLE analytics.uncategorized TO uncategorized_reader;

GRANT SELECT ON ALL TABLES IN SCHEMA trusted_data, analytics TO all_analytics_reader;

GRANT USAGE, CREATE ON SCHEMA analytics TO data_science_full_access;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_science_full_access;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA analytics TO data_science_full_access;

--==================================================================================
-- SEÇÃO C: LIDANDO COM OBJETOS FUTUROS
--==================================================================================
ALTER DEFAULT PRIVILEGES IN SCHEMA trusted_data
    GRANT SELECT ON TABLES TO all_analytics_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT SELECT ON TABLES TO all_analytics_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_science_full_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT USAGE, SELECT ON SEQUENCES TO data_science_full_access;

--==================================================================================
-- SEÇÃO D: CRIAÇÃO DOS USUÁRIOS FINAIS
--==================================================================================
CREATE ROLE analyst_all LOGIN PASSWORD '48YJOKk8g5s';
CREATE ROLE data_scientist LOGIN PASSWORD '78Fp9F7nXZ1';
CREATE ROLE analyst_movies LOGIN PASSWORD 'N5Nepksq6D7';
CREATE ROLE analyst_tv LOGIN PASSWORD 'D8bZytl1r5o';
CREATE ROLE analyst_games LOGIN PASSWORD '68294PoYboR';
CREATE ROLE analyst_docs LOGIN PASSWORD 'ULqbdm074o2';
CREATE ROLE analyst_shorts LOGIN PASSWORD '8s9Ks2fjVEY';
CREATE ROLE analyst_theater LOGIN PASSWORD 'CFhV9b8gaz2';
CREATE ROLE analyst_adults LOGIN PASSWORD '92FRS06QoSu';
CREATE ROLE analyst_uncategorized LOGIN PASSWORD '9uzN00sR9mi';

--==================================================================================
-- SEÇÃO E: ATRIBUIÇÃO DOS "CRACHÁS" (ROLES DE GRUPO) AOS USUÁRIOS
--==================================================================================
GRANT analyst_base, all_analytics_reader TO analyst_all;
GRANT analyst_base, data_science_full_access TO data_scientist;
GRANT analyst_base, movies_reader TO analyst_movies;
GRANT analyst_base, tv_shows_reader TO analyst_tv;
GRANT analyst_base, games_reader TO analyst_games;
GRANT analyst_base, docs_reader TO analyst_docs;
GRANT analyst_base, short_films_reader TO analyst_shorts;
GRANT analyst_base, theater_prod_reader TO analyst_theater;
GRANT analyst_base, adult_films_reader TO analyst_adults;
GRANT analyst_base, uncategorized_reader TO analyst_uncategorized;