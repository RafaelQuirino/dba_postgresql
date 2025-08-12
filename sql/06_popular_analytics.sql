-- Move cada produção para sua tabela específica conforme tipo_id
INSERT INTO analytics.movies        SELECT * FROM raw_data.producao WHERE tipo_id = 1;
INSERT INTO analytics.tv_shows      SELECT * FROM raw_data.producao WHERE tipo_id = 2;
INSERT INTO analytics.documentaries SELECT * FROM raw_data.producao WHERE tipo_id = 3;
INSERT INTO analytics.short_films   SELECT * FROM raw_data.producao WHERE tipo_id = 4;
INSERT INTO analytics.music_videos  SELECT * FROM raw_data.producao WHERE tipo_id = 5;
INSERT INTO analytics.video_games   SELECT * FROM raw_data.producao WHERE tipo_id = 6;
INSERT INTO analytics.animations    SELECT * FROM raw_data.producao WHERE tipo_id = 7;

-- Extras (opcionais): theater_productions e web_series podem ser populadas
-- quando você tiver as regras/IDs correspondentes na sua base.
