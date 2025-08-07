

-- Insere dados iniciais na tabela analytics.production_types
INSERT INTO analytics.production_types (tipo_id, descricao) VALUES
(1, 'Movie'),
(2, 'TV Show'),
(3, 'Documentary'),
(4, 'Short Film'),
(5, 'TV Show'),
(6, 'Video Game'),
(7, 'Web Series')
ON CONFLICT (tipo_id) DO NOTHING;

-- Popula a tabela analytics.movies com dados da tabela raw_data.producoes
-- tipo_id 1 = Movie
INSERT INTO analytics.movies (movie_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id = 1
ON CONFLICT (movie_id) DO NOTHING;

-- tipo_id 2 e 5 = TV Show
INSERT INTO analytics.tv_shows (tv_show_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id IN (2, 5)
ON CONFLICT (tv_show_id) DO NOTHING;

-- tipo_id 3 = Documentary
INSERT INTO analytics.documentaries (documentary_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id = 3
ON CONFLICT (documentary_id) DO NOTHING;

-- tipo_id 4 = Short Film
INSERT INTO analytics.short_films (short_film_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id = 4
ON CONFLICT (short_film_id) DO NOTHING;

-- tipo_id 6 = Video Game
INSERT INTO analytics.video_games (video_game_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id = 6
ON CONFLICT (video_game_id) DO NOTHING;

-- tipo_id 7 = Web Series
INSERT INTO analytics.web_series (web_series_id, title, year)
SELECT producao_id, titulo, ano
FROM raw_data.producoes
WHERE tipo_id = 7
ON CONFLICT (web_series_id) DO NOTHING;

-- Popula pessoas e quipes
-- Persons
INSERT INTO analytics.persons (person_id, name)
SELECT p.pessoa_id, p.nome
FROM raw_data.pessoas p
ON CONFLICT (person_id) DO UPDATE SET name = EXCLUDED.name;

-- Crew
INSERT INTO analytics.crew (person_id, production_type, production_id, job)
SELECT
    e.pessoa_id AS person_id,
    CASE
        WHEN pr.tipo_id = 1 THEN 'movie'
        WHEN pr.tipo_id IN (2,5) THEN 'tv_show'
        WHEN pr.tipo_id = 3 THEN 'documentary'
        WHEN pr.tipo_id = 4 THEN 'short_film'
        WHEN pr.tipo_id = 6 THEN 'video_game'
        WHEN pr.tipo_id = 7 THEN 'web_series'
        -- Tipos não mapeados podem ser tratados aqui (ex.: 'music_video','theater','animation')
        ELSE 'movie'  -- fallback opcional (ajuste se preferir falhar)
    END AS production_type,
    e.producao_id AS production_id,
    e.papel       AS job
FROM raw_data.equipes e
JOIN raw_data.producoes pr ON pr.producao_id = e.producao_id
-- Garante que a pessoa existe em analytics.persons (FK já cobre, mas isso evita erro em massa)
JOIN analytics.persons ap ON ap.person_id = e.pessoa_id
ON CONFLICT (person_id, production_type, production_id, job) DO NOTHING;