-- T01_validation_state.sql
-- Objetivo: Validar a criação dos schemas, tabelas e a ingestão de dados.

\echo '>> 1. Verificando a existência dos Schemas...'
SELECT nspname AS schema_name
FROM pg_namespace
WHERE nspname IN ('raw_data', 'analytics');

\echo '>> 2. Verificando a existência das tabelas no schema raw_data...'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw_data';

\echo '>> 3. Verificando a contagem de registros nas tabelas raw_data (deve ser > 0)...'
SELECT 'producao' as tabela, COUNT(1) FROM raw_data.producao
UNION ALL
SELECT 'pessoa' as tabela, COUNT(1) FROM raw_data.pessoa
UNION ALL
SELECT 'equipe' as tabela, COUNT(1) FROM raw_data.equipe;

\echo '>> 4. Verificando a existência das tabelas no schema analytics...'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'analytics' AND table_type = 'BASE TABLE';

\echo '>> 5. Verificando a contagem de registros em uma tabela de analytics (deve ser > 0)...'
-- Testamos a tabela de filmes como amostra.
SELECT 'movies' as tabela, COUNT(1) FROM analytics.movies;

\echo '>> 6. Verificando a existência das views no schema analytics...'
SELECT table_name as view_name
FROM information_schema.tables
WHERE table_schema = 'analytics' AND table_type = 'VIEW';