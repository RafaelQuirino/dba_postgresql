-- RAW DATA ----------------------------------------------------
CREATE TABLE IF NOT EXISTS raw_data.producoes (
    producao_id INT PRIMARY KEY,
    titulo      VARCHAR(255) NOT NULL,
    ano         INT NOT NULL,
    tipo_id     INT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_producoes_tipo_id ON raw_data.producoes(tipo_id);

CREATE TABLE IF NOT EXISTS raw_data.pessoas (
    pessoa_id INT PRIMARY KEY,
    nome      VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.equipes (
    pessoa_id   INT NOT NULL,
    producao_id INT NOT NULL,
    papel       TEXT NOT NULL,
    PRIMARY KEY (pessoa_id, producao_id),
    FOREIGN KEY (pessoa_id) REFERENCES raw_data.pessoas(pessoa_id),
    FOREIGN KEY (producao_id) REFERENCES raw_data.producoes(producao_id)
);

-- ANALYTICS ---------------------------------------------------
CREATE TABLE IF NOT EXISTS analytics.production_types (
    tipo_id   INT PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

-- tabelas por tipo de produção
CREATE TABLE IF NOT EXISTS analytics.movies            (movie_id           INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.tv_shows          (tv_show_id         INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.video_games       (video_game_id      INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.documentaries     (documentary_id     INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.short_films       (short_film_id      INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.music_videos      (music_video_id     INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.theater_productions (theater_production_id INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.web_series        (web_series_id      INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);
CREATE TABLE IF NOT EXISTS analytics.animations        (animation_id       INT PRIMARY KEY, title VARCHAR(255) NOT NULL, year INT NOT NULL);

-- pessoas e crew
CREATE TABLE IF NOT EXISTS analytics.persons (
    person_id INT PRIMARY KEY,
    name      VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.crew (
    person_id        INT NOT NULL REFERENCES analytics.persons(person_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    production_type  VARCHAR(50) NOT NULL,
    production_id    INT NOT NULL,
    job              TEXT NOT NULL,
    PRIMARY KEY (person_id, production_type, production_id, job),
    CONSTRAINT crew_production_type_chk CHECK (production_type IN (
        'movie','tv_show','video_game','documentary','short_film',
        'music_video','theater','web_series','animation'
    ))
);

-- Índices úteis
CREATE INDEX IF NOT EXISTS idx_crew_production ON analytics.crew (production_type, production_id);
CREATE INDEX IF NOT EXISTS idx_crew_job       ON analytics.crew (job);
CREATE INDEX IF NOT EXISTS idx_crew_person    ON analytics.crew (person_id);

-- SEEDS (opc) -----------------------------------------------
-- production_types (ajustado p/ não repetir TV Show)
INSERT INTO analytics.production_types (tipo_id, descricao) VALUES
(1,'Movie'),
(2,'TV Show'),
(3,'Documentary'),
(4,'Short Film'),
(6,'Video Game'),
(7,'Web Series')
ON CONFLICT (tipo_id) DO NOTHING;

-- Popular tabelas analytics a partir do raw_data
INSERT INTO analytics.movies (movie_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id = 1
ON CONFLICT (movie_id) DO NOTHING;

INSERT INTO analytics.tv_shows (tv_show_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id IN (2,5)
ON CONFLICT (tv_show_id) DO NOTHING;

INSERT INTO analytics.documentaries (documentary_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id = 3
ON CONFLICT (documentary_id) DO NOTHING;

INSERT INTO analytics.short_films (short_film_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id = 4
ON CONFLICT (short_film_id) DO NOTHING;

INSERT INTO analytics.video_games (video_game_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id = 6
ON CONFLICT (video_game_id) DO NOTHING;

INSERT INTO analytics.web_series (web_series_id, title, year)
SELECT producao_id, titulo, ano FROM raw_data.producoes WHERE tipo_id = 7
ON CONFLICT (web_series_id) DO NOTHING;

-- Persons
INSERT INTO analytics.persons (person_id, name)
SELECT p.pessoa_id, p.nome
FROM raw_data.pessoas p
ON CONFLICT (person_id) DO UPDATE SET name = EXCLUDED.name;

-- Crew
INSERT INTO analytics.crew (person_id, production_type, production_id, job)
SELECT
  e.pessoa_id,
  CASE
    WHEN pr.tipo_id = 1 THEN 'movie'
    WHEN pr.tipo_id IN (2,5) THEN 'tv_show'
    WHEN pr.tipo_id = 3 THEN 'documentary'
    WHEN pr.tipo_id = 4 THEN 'short_film'
    WHEN pr.tipo_id = 6 THEN 'video_game'
    WHEN pr.tipo_id = 7 THEN 'web_series'
    ELSE 'movie'
  END,
  e.producao_id,
  e.papel
FROM raw_data.equipes e
JOIN raw_data.producoes pr ON pr.producao_id = e.producao_id
JOIN analytics.persons ap  ON ap.person_id = e.pessoa_id
ON CONFLICT (person_id, production_type, production_id, job) DO NOTHING;