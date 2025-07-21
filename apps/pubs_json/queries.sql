-- Queries para análise dos dados do arquivo pubs.json

-- Top 10 Advogados mais Ativos
SELECT a.nome, a.numero_oab, a.uf_oab, COUNT(*) AS total_publicacoes
FROM destinatario_advogado da
JOIN advogado a ON da.advogado_id = a.id
GROUP BY a.id, a.nome, a.numero_oab, a.uf_oab
ORDER BY total_publicacoes DESC
LIMIT 10;

-- Tipos de Publicacoes mais Comuns
SELECT tipo_comunicacao, COUNT(*) AS total
FROM publicacao
GROUP BY tipo_comunicacao
ORDER BY total DESC;

-- Top 10 Destinatarios mais Notificados
SELECT nome, COUNT(*) AS total_notificacoes
FROM destinatario
GROUP BY nome
ORDER BY total_notificacoes DESC
LIMIT 10;

-- Classes de Casos mais Comuns
SELECT nome_classe, COUNT(*) AS total
FROM publicacao
GROUP BY nome_classe
ORDER BY total DESC
LIMIT 10;

-- Publicacoes Recentes
SELECT id, data_disponibilizacao, nome_classe, nome_orgao, tipo_comunicacao
FROM publicacao
ORDER BY data_disponibilizacao DESC
LIMIT 10;

-- Publicacoes por Orgao
SELECT nome_orgao, COUNT(*) AS total
FROM publicacao
GROUP BY nome_orgao
ORDER BY total DESC
LIMIT 10; 