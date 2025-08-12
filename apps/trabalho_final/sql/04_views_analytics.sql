-- Views unificadas e de apoio

CREATE OR REPLACE VIEW analytics.productions_unified AS
SELECT movie_id        AS production_id, title, year, 'movie'          AS production_type FROM analytics.movies
UNION ALL
SELECT tv_show_id      AS production_id, title, year, 'tv_show'        AS production_type FROM analytics.tv_shows
UNION ALL
SELECT video_game_id   AS production_id, title, year, 'video_game'     AS production_type FROM analytics.video_games
UNION ALL
SELECT documentary_id  AS production_id, title, year, 'documentary'    AS production_type FROM analytics.documentaries
UNION ALL
SELECT short_film_id   AS production_id, title, year, 'short_film'     AS production_type FROM analytics.short_films
UNION ALL
SELECT music_video_id  AS production_id, title, year, 'music_video'    AS production_type FROM analytics.music_videos
UNION ALL
SELECT theater_production_id AS production_id, title, year, 'theater'  AS production_type FROM analytics.theater_productions
UNION ALL
SELECT web_series_id   AS production_id, title, year, 'web_series'     AS production_type FROM analytics.web_series
UNION ALL
SELECT animation_id    AS production_id, title, year, 'animation'      AS production_type FROM analytics.animations;

-- Resumo por tipo
CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT
  production_type,
  COUNT(*) AS total_titles,
  MIN(year) AS first_year,
  MAX(year) AS last_year
FROM analytics.productions_unified
GROUP BY production_type
ORDER BY production_type;

-- Tendências anuais por tipo
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT
  year,
  production_type,
  COUNT(*) AS total_titles
FROM analytics.productions_unified
GROUP BY year, production_type
ORDER BY year, production_type;

-- Top “atores/profissionais” por tipo (contagem de participações)
CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
WITH actor_counts AS (
  SELECT
    c.production_type,
    p.person_id,
    p.name,
    COUNT(*) AS appearances
  FROM analytics.crew c
  JOIN analytics.persons p ON p.person_id = c.person_id
  GROUP BY c.production_type, p.person_id, p.name
)
SELECT
  production_type,
  person_id,
  name,
  appearances,
  RANK() OVER (PARTITION BY production_type ORDER BY appearances DESC, name ASC) AS rank_per_type
FROM actor_counts
ORDER BY production_type, rank_per_type, name;

-- Análise de crew por tipo e job
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT
  cr.production_type,
  cr.job,
  COUNT(*)                     AS total_participations,
  COUNT(DISTINCT cr.person_id) AS distinct_professionals
FROM analytics.crew cr
GROUP BY cr.production_type, cr.job
ORDER BY cr.production_type, cr.job;