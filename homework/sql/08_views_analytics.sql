-- =============================
-- Fase 4: Analytics e Relatórios
-- Passo 6: Views Analíticas
-- =============================

CREATE OR REPLACE VIEW analytics.production_summary AS
SELECT 'movies' AS tipo, COUNT(*) AS total FROM analytics.movies
UNION ALL
SELECT 'tv_shows', COUNT(*) FROM analytics.tv_shows
UNION ALL
SELECT 'video_games', COUNT(*) FROM analytics.video_games
UNION ALL
SELECT 'documentaries', COUNT(*) FROM analytics.documentaries
UNION ALL
SELECT 'short_films', COUNT(*) FROM analytics.short_films
UNION ALL
SELECT 'music_videos', COUNT(*) FROM analytics.music_videos
UNION ALL
SELECT 'theater_productions', COUNT(*) FROM analytics.theater_productions
UNION ALL
SELECT 'web_series', COUNT(*) FROM analytics.web_series
UNION ALL
SELECT 'animations', COUNT(*) FROM analytics.animations;

CREATE OR REPLACE VIEW analytics.top_actors_by_type AS
SELECT tipo, nome, total
FROM (
  SELECT 'movies' AS tipo, ps.nome, COUNT(*) AS total,
         ROW_NUMBER() OVER (PARTITION BY 'movies' ORDER BY COUNT(*) DESC) AS rn
    FROM analytics.movies m
    JOIN raw_data.equipe e ON m.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'tv_shows', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'tv_shows' ORDER BY COUNT(*) DESC)
    FROM analytics.tv_shows t
    JOIN raw_data.equipe e ON t.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'video_games', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'video_games' ORDER BY COUNT(*) DESC)
    FROM analytics.video_games v
    JOIN raw_data.equipe e ON v.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'documentaries', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'documentaries' ORDER BY COUNT(*) DESC)
    FROM analytics.documentaries d
    JOIN raw_data.equipe e ON d.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'short_films', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'short_films' ORDER BY COUNT(*) DESC)
    FROM analytics.short_films s
    JOIN raw_data.equipe e ON s.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'music_videos', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'music_videos' ORDER BY COUNT(*) DESC)
    FROM analytics.music_videos mv
    JOIN raw_data.equipe e ON mv.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'theater_productions', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'theater_productions' ORDER BY COUNT(*) DESC)
    FROM analytics.theater_productions th
    JOIN raw_data.equipe e ON th.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'web_series', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'web_series' ORDER BY COUNT(*) DESC)
    FROM analytics.web_series ws
    JOIN raw_data.equipe e ON ws.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
  UNION ALL
  SELECT 'animations', ps.nome, COUNT(*),
         ROW_NUMBER() OVER (PARTITION BY 'animations' ORDER BY COUNT(*) DESC)
    FROM analytics.animations a
    JOIN raw_data.equipe e ON a.producao_id = e.producao_id
    JOIN raw_data.pessoa ps ON e.pessoa_id = ps.pessoa_id
    GROUP BY ps.nome
) sub
WHERE rn <= 10;

CREATE OR REPLACE VIEW analytics.yearly_production_trends AS
SELECT ano_producao, tipo, total
FROM (
  SELECT ano_producao, 'movies' AS tipo, COUNT(*) AS total FROM analytics.movies GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'tv_shows', COUNT(*) FROM analytics.tv_shows GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'video_games', COUNT(*) FROM analytics.video_games GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'documentaries', COUNT(*) FROM analytics.documentaries GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'short_films', COUNT(*) FROM analytics.short_films GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'music_videos', COUNT(*) FROM analytics.music_videos GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'theater_productions', COUNT(*) FROM analytics.theater_productions GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'web_series', COUNT(*) FROM analytics.web_series GROUP BY ano_producao
  UNION ALL
  SELECT ano_producao, 'animations', COUNT(*) FROM analytics.animations GROUP BY ano_producao
) t
ORDER BY ano_producao, tipo;

CREATE OR REPLACE VIEW analytics.crew_analysis AS
SELECT p.producao_id, p.titulo, p.ano_producao, e.papel, COUNT(*) AS total_pessoas_mesmo_papel
FROM (
  SELECT producao_id, titulo, ano_producao FROM analytics.movies
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.tv_shows
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.video_games
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.documentaries
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.short_films
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.music_videos
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.theater_productions
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.web_series
  UNION ALL
  SELECT producao_id, titulo, ano_producao FROM analytics.animations
) p
JOIN raw_data.equipe e ON p.producao_id = e.producao_id
GROUP BY p.producao_id, p.titulo, p.ano_producao, e.papel;
