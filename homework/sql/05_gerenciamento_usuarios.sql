-- Criação dos usuários
CREATE USER analyst_movies WITH PASSWORD 'analyst_movies_pwd';
CREATE USER analyst_tv WITH PASSWORD 'analyst_tv_pwd';
CREATE USER analyst_games WITH PASSWORD 'analyst_games_pwd';
CREATE USER analyst_docs WITH PASSWORD 'analyst_docs_pwd';
CREATE USER analyst_all WITH PASSWORD 'analyst_all_pwd';
CREATE USER data_scientist WITH PASSWORD 'data_scientist_pwd';

-- Permissões para cada usuário
-- analyst_movies: acesso somente leitura à tabela de filmes
GRANT USAGE ON SCHEMA analytics TO analyst_movies;
GRANT SELECT ON analytics.movies TO analyst_movies;

-- analyst_tv: acesso somente leitura à tabela de séries de TV
GRANT USAGE ON SCHEMA analytics TO analyst_tv;
GRANT SELECT ON analytics.tv_shows TO analyst_tv;

-- analyst_games: acesso somente leitura à tabela de videogames
GRANT USAGE ON SCHEMA analytics TO analyst_games;
GRANT SELECT ON analytics.video_games TO analyst_games;

-- analyst_docs: acesso somente leitura à tabela de documentários
GRANT USAGE ON SCHEMA analytics TO analyst_docs;
GRANT SELECT ON analytics.documentaries TO analyst_docs;

-- analyst_all: acesso somente leitura a todas as tabelas analíticas
GRANT USAGE ON SCHEMA analytics TO analyst_all;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analyst_all;

-- data_scientist: acesso total (leitura e escrita) ao schema analytics
GRANT USAGE ON SCHEMA analytics TO data_scientist;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO data_scientist;
GRANT ALL PRIVILEGES ON SCHEMA analytics TO data_scientist;

-- Permissão de leitura em pessoa e equipe (analytics) para todos os analistas
GRANT SELECT ON analytics.pessoa TO analyst_movies;
GRANT SELECT ON analytics.pessoa TO analyst_tv;
GRANT SELECT ON analytics.pessoa TO analyst_games;
GRANT SELECT ON analytics.pessoa TO analyst_docs;
GRANT SELECT ON analytics.pessoa TO analyst_all;
GRANT SELECT ON analytics.pessoa TO data_scientist;

-- Caso exista analytics.equipe, conceder também:
GRANT SELECT ON analytics.equipe TO analyst_movies;
GRANT SELECT ON analytics.equipe TO analyst_tv;
GRANT SELECT ON analytics.equipe TO analyst_games;
GRANT SELECT ON analytics.equipe TO analyst_docs;
GRANT SELECT ON analytics.equipe TO analyst_all;
GRANT SELECT ON analytics.equipe TO data_scientist;

-- Revogar permissões extras (garantia de segurança)
REVOKE ALL ON SCHEMA analytics FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA analytics FROM PUBLIC;


-- =============================
-- Testes de acesso dos usuários especializados
-- =============================

-- Testar acesso do usuário analyst_movies
-- \c cinetech_productions analyst_movies analyst_movies_pwd
-- Deve funcionar:
SELECT COUNT(*) FROM analytics.movies;
-- Deve falhar (sem permissão):
SELECT COUNT(*) FROM analytics.tv_shows;

-- Testar acesso do usuário analyst_tv
-- \c cinetech_productions analyst_tv analyst_tv_pwd
SELECT COUNT(*) FROM analytics.tv_shows; -- Deve funcionar
SELECT COUNT(*) FROM analytics.movies;   -- Deve falhar

-- Testar acesso do usuário analyst_games
-- \c cinetech_productions analyst_games analyst_games_pwd
SELECT COUNT(*) FROM analytics.video_games; -- Deve funcionar
SELECT COUNT(*) FROM analytics.movies;      -- Deve falhar

-- Testar acesso do usuário analyst_docs
-- \c cinetech_productions analyst_docs analyst_docs_pwd
SELECT COUNT(*) FROM analytics.documentaries; -- Deve funcionar
SELECT COUNT(*) FROM analytics.movies;        -- Deve falhar

-- Testar acesso do usuário analyst_all
-- \c cinetech_productions analyst_all analyst_all_pwd
SELECT COUNT(*) FROM analytics.movies;         -- Deve funcionar
SELECT COUNT(*) FROM analytics.tv_shows;       -- Deve funcionar
SELECT COUNT(*) FROM analytics.video_games;    -- Deve funcionar
SELECT COUNT(*) FROM analytics.documentaries;  -- Deve funcionar
SELECT COUNT(*) FROM analytics.short_films;    -- Deve funcionar
SELECT COUNT(*) FROM analytics.music_videos;   -- Deve funcionar
SELECT COUNT(*) FROM analytics.theater_productions; -- Deve funcionar
SELECT COUNT(*) FROM analytics.web_series;     -- Deve funcionar
SELECT COUNT(*) FROM analytics.animations;     -- Deve funcionar
-- Deve falhar (sem permissão de escrita):
INSERT INTO analytics.movies (producaoid, titulo, ano_producao, producao_tipo_id) VALUES (999999, 'Teste', 2025, 1);

-- Testar acesso do usuário data_scientist
-- \c cinetech_productions data_scientist data_scientist_pwd
SELECT COUNT(*) FROM analytics.movies;         -- Deve funcionar
INSERT INTO analytics.movies (producaoid, titulo, ano_producao, producao_tipo_id) VALUES (999998, 'Teste DS', 2025, 1); -- Deve funcionar
