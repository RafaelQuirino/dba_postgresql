-- Tabelas especializadas por tipo (todas com as mesmas colunas da base)
CREATE TABLE IF NOT EXISTS analytics.movies        (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.tv_shows      (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.video_games   (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.documentaries (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.short_films   (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.music_videos  (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.theater_productions (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.web_series    (LIKE raw_data.producao INCLUDING ALL);
CREATE TABLE IF NOT EXISTS analytics.animations    (LIKE raw_data.producao INCLUDING ALL);
