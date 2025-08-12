-- Função para processar as publicações
CREATE OR REPLACE FUNCTION processar_publicacao()
RETURNS TRIGGER AS $$
DECLARE
    processo_match TEXT;
    juizado_match TEXT;
    juiz_match TEXT;
    advogados_text TEXT;
    advogado_nome TEXT;
    advogado_oab TEXT;
    advogado_id INTEGER;
    juiz_id INTEGER;
BEGIN
    -- Extrair número do processo
    SELECT (regexp_matches(NEW.texto, '\d{1,7}-\d{2}\.\d{4}\.\d\.\d{2}\.\d{4}'))[1] 
    INTO processo_match;
    
    -- Atualizar coluna processo se encontrado
    IF processo_match IS NOT NULL THEN
        UPDATE publicacoes SET processo = processo_match WHERE id = NEW.id;
    END IF;
    
	-- Extrair juizado (até antes da linha do juiz)
	SELECT (regexp_matches(NEW.texto, 'JU[IÍ]ZO\s+DE\s+DIREITO\s+(?:DA|DO|DE)?\s*([\s\S]+?)(?=JUIZ\(A\)\s+DE\s+DIREITO)', 'i'))[1]
	INTO juizado_match;
    
    -- Atualizar coluna juizado se encontrado
    IF juizado_match IS NOT NULL THEN
        UPDATE publicacoes SET juizado = juizado_match WHERE id = NEW.id;
    END IF;
    
    -- Extrair juiz (até antes de ESCRIVÃ(O), mesma ou próxima linha)
	SELECT (regexp_matches(NEW.texto, 'JUIZ\(A\)\s+DE\s+DIREITO\s+([\s\S]+?)(?=ESCRIVÃ\(O\))', 'i'))[1]
	INTO juiz_match;

    -- Inserir juiz se encontrado e nome for razoável
    IF juiz_match IS NOT NULL AND length(juiz_match) <= 255 THEN
        -- Verificar se juiz já existe
        SELECT id INTO juiz_id FROM juizes WHERE nome = juiz_match;
        IF NOT FOUND THEN
            INSERT INTO juizes (nome) VALUES (juiz_match) RETURNING id INTO juiz_id;
        END IF;
        
        -- Associar juiz à publicação
        INSERT INTO publicacoes_juizes (id_publicacao, id_juiz)
        VALUES (NEW.id, juiz_id)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Extrair bloco de advogados
    SELECT (regexp_matches(NEW.texto, 'ADV:(.*?)(?=-----###-----|$)', 's'))[1]
    INTO advogados_text;
    
    -- Processar cada advogado encontrado
    IF advogados_text IS NOT NULL THEN
        FOR advogado_nome, advogado_oab IN
            SELECT 
                TRIM(regexp_replace(m[1], '\s+', ' ', 'g')),
                m[2]
            FROM regexp_matches(advogados_text, '([^,\(]+?)\s*\(OAB\s*(\d+/[A-Z]{2})\)', 'g') AS m
        LOOP
            -- Ignorar se nome for muito grande
            IF length(advogado_nome) > 255 THEN
                CONTINUE;
            END IF;

            -- Verificar se advogado já existe
            SELECT id INTO advogado_id FROM advogados WHERE oab = advogado_oab;
            IF NOT FOUND THEN
                INSERT INTO advogados (nome, oab) 
                VALUES (advogado_nome, advogado_oab) 
                RETURNING id INTO advogado_id;
            END IF;
            
            -- Associar advogado à publicação
            INSERT INTO publicacoes_advogados (id_publicacao, id_advogado)
            VALUES (NEW.id, advogado_id)
            ON CONFLICT DO NOTHING;
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

