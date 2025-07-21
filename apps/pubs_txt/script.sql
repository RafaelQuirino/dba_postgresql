
-- Exemplo pratico: dados juridicos
---
-- 1. Consultas DDL para criacao das tabelas
---
-- Tabela de publicações
CREATE TABLE publicacoes (
    id SERIAL PRIMARY KEY,
    texto TEXT NOT NULL,
    processo TEXT
);

-- Tabela de advogados
CREATE TABLE advogados (
    id_publicacao INTEGER NOT NULL REFERENCES publicacoes(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    oab TEXT NOT NULL
);

--
-- 2. Função PL/pgSQL e Trigger
---
-- Função para processar as publicações
CREATE OR REPLACE FUNCTION processar_publicacao()
RETURNS TRIGGER AS $$
DECLARE
    processo_match TEXT;
    advogados_text TEXT;
    advogado_record RECORD;
BEGIN
    -- Extrair número do processo
    SELECT (regexp_matches(NEW.texto, '\d{1,7}-\d{2}\.\d{4}\.\d\.\d{2}\.\d{4}'))[1]
    INTO processo_match;

    -- Atualizar coluna processo se encontrado
    IF processo_match IS NOT NULL THEN
        UPDATE publicacoes SET processo = processo_match WHERE id = NEW.id;
    END IF;

    -- Extrair bloco de advogados
    SELECT (regexp_matches(NEW.texto, 'ADV:(.*?)(?=-----###-----|$)', 's'))[1]
    INTO advogados_text;

    -- Processar cada advogado encontrado
    IF advogados_text IS NOT NULL THEN
        FOR advogado_record IN
            SELECT
                TRIM(regexp_replace(m[1], '\s+', ' ', 'g')) AS nome,
                m[2] AS oab
            FROM regexp_matches(advogados_text, '([^,\(]+?)\s*\(OAB\s*(\d+/[A-Z]{2})\)', 'g') AS m
        LOOP
            INSERT INTO advogados (id_publicacao, nome, oab)
            VALUES (NEW.id, advogado_record.nome, advogado_record.oab);
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
CREATE TRIGGER trigger_processar_publicacao
AFTER INSERT ON publicacoes
FOR EACH ROW
EXECUTE FUNCTION processar_publicacao();
