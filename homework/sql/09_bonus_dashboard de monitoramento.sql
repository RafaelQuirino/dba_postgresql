CREATE OR REPLACE VIEW analytics.dashboard_monitoramento AS
SELECT
    (SELECT COUNT(*) FROM raw_data.producao) AS total_producoes,
    (SELECT COUNT(*) FROM raw_data.pessoa) AS total_pessoas,
    (SELECT COUNT(*) FROM raw_data.equipe) AS total_equipes,
    (SELECT COUNT(*) FROM analytics.movies) AS total_movies,
    (SELECT COUNT(*) FROM analytics.tv_shows) AS total_tv_shows,
    (SELECT MIN(ano) FROM raw_data.producao) AS ano_mais_antigo,
    (SELECT MAX(ano) FROM raw_data.producao) AS ano_mais_recente;

SELECT * FROM analytics.dashboard_monitoramento;
