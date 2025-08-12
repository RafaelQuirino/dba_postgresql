-- 1) production_summary
CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT 'movies' AS tipo, COUNT(*)::BIGINT AS total FROM analytics.movies
UNION ALL SELECT 'tv_shows',      COUNT(*) FROM analytics.tv_shows
UNION ALL SELECT 'video_games',   COUNT(*) FROM analytics.video_games
UNION ALL SELECT 'documentaries', COUNT(*) FROM analytics.documentaries
UNION ALL SELECT 'short_films',   COUNT(*) FROM analytics.short_films
UNION ALL SELECT 'music_videos',  COUNT(*) FROM analytics.music_videos
UNION ALL SELECT 'theater_productions', COUNT(*) FROM analytics.theater_productions
UNION ALL SELECT 'web_series',    COUNT(*) FROM analytics.web_series
UNION ALL SELECT 'animations',    COUNT(*) FROM analytics.animations;

-- 2) top_actors_by_type
CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
WITH tipo_map AS (
  SELECT 1 AS tipo_id, 'movies' tipo UNION ALL
  SELECT 2, 'tv_shows' UNION ALL
  SELECT 3, 'documentaries' UNION ALL
  SELECT 4, 'short_films' UNION ALL
  SELECT 5, 'music_videos' UNION ALL
  SELECT 6, 'video_games' UNION ALL
  SELECT 7, 'animations'
)
SELECT m.tipo, pe.nome, COUNT(*) AS participacoes
FROM raw_data.equipe e
JOIN raw_data.pessoa pe ON pe.pessoa_id = e.pessoa_id
JOIN raw_data.producao p ON p.producao_id = e.producao_id
JOIN tipo_map m ON m.tipo_id = p.tipo_id
GROUP BY 1,2
ORDER BY m.tipo, participacoes DESC;

-- 3) yearly_production_trends
CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT ano_producao, COUNT(*)::BIGINT qtd
FROM raw_data.producao
WHERE ano_producao IS NOT NULL
GROUP BY ano_producao
ORDER BY ano_producao;

-- 4) crew_analysis
CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT LOWER(COALESCE(papel,'(sem papel)')) AS papel, COUNT(*)::BIGINT qtd
FROM raw_data.equipe
GROUP BY 1
ORDER BY qtd DESC;
