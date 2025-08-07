CREATE OR REPLACE FUNCTION processar_publicacao()
RETURNS TRIGGER AS $$
DECLARE
    processo_match TEXT;
BEGIN
    -- Extrair número do processo
    SELECT (regexp_matches(NEW.texto, '\d{1,7}-\d{2}\.\d{4}\.\d\.\d{2}\.\d{4}'))[1]
    INTO processo_match;

    -- Atualizar coluna processo se encontrado
    IF processo_match IS NOT NULL THEN
        UPDATE publicacoes SET processo = processo_match WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
CREATE TRIGGER trigger_processar_publicacao
AFTER INSERT ON publicacoes
FOR EACH ROW
EXECUTE FUNCTION processar_publicacao();
