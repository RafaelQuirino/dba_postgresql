-- Garante que o schema para a camada Silver (trusted) exista
CREATE SCHEMA IF NOT EXISTS trusted_data;

/*************************************************************************
 * SCRIPT DE CORREÇÃO E ATUALIZAÇÃO DAS VIEWS DA CAMADA SILVER
 *
 * Corrige os problemas de ano=0 e papel=null.
 *************************************************************************/

-- Apaga as views na ordem inversa para evitar erros de dependência
DROP VIEW IF EXISTS trusted_data.vw_equipe_completa;
DROP VIEW IF EXISTS trusted_data.vw_producoes;

---
-- VIEW PARA PRODUÇÕES (Silver) - VERSÃO CORRIGIDA
---
CREATE VIEW trusted_data.vw_producoes AS
SELECT
    "producaoID",
    titulo,
    -- CORREÇÃO AQUI: Substitui o ano 0 por NULL para manter a integridade dos dados.
    NULLIF(ano_producao, 0) AS ano_producao,
    CASE
        WHEN "tipo_ID" = 1 THEN 'Filme'
        WHEN "tipo_ID" = 2 THEN 'Série de TV'
        WHEN "tipo_ID" = 3 THEN 'Documentário'
        WHEN "tipo_ID" = 4 THEN 'Filmes Adultos'
        WHEN "tipo_ID" = 5 THEN 'Produção Teatral'
        WHEN "tipo_ID" = 6 THEN 'Videogame'
        WHEN "tipo_ID" = 7 THEN 'Curta-metragem'
        ELSE 'Não categorizado'
    END AS tipo_producao
FROM
    raw_data.producao;

---
-- VIEW PARA A EQUIPE COMPLETA (Silver) - VERSÃO CORRIGIDA
---
CREATE VIEW trusted_data.vw_equipe_completa AS
SELECT
    p."producaoID",
    p.titulo,
    p.ano_producao, -- Já herda o ano corrigido da view anterior
    p.tipo_producao,
    ps."pessoaID",
    ps.nome AS nome_pessoa,
    -- CORREÇÃO AQUI: Substitui o papel NULL por um valor padrão.
    COALESCE(NULLIF(e.papel, 'null'), 'Papel Não Identificado') AS papel
FROM
    trusted_data.vw_producoes AS p
INNER JOIN
    raw_data.equipe AS e ON p."producaoID" = e."producaoID"
INNER JOIN
    raw_data.pessoa AS ps ON ps."pessoaID" = e."pessoaID";