

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