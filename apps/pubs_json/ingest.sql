-- Ingestão de dados da tabela pubs_staging para tabelas normalizadas

-- 1. Inserir metadados
INSERT INTO pubs_metadata (tribunal, md5)
SELECT data->>'tribunal', data->>'md5'
FROM pubs_staging
ON CONFLICT DO NOTHING;

-- 2. Inserir registros na tabela publicacao
INSERT INTO publicacao (
    id, md5, ativo, codigo_classe, data_disponibilizacao, datadisponibilizacao, dataenvio,
    hash, link, meio, meiocompleto, motivo_cancelamento, nome_classe, nome_orgao,
    numero_comunicacao, numero_processo, numeroprocessocommascara, orgao_id, sigla_tribunal,
    status, texto, tipo_comunicacao, tipo_documento
)
SELECT
    (item->>'id')::bigint,
    item->>'md5',
    (item->>'ativo')::boolean,
    item->>'codigoClasse',
    (item->>'data_disponibilizacao')::date,
    item->>'datadisponibilizacao',
    to_date(item->>'dataenvio', 'DD/MM/YYYY'),
    item->>'hash',
    item->>'link',
    item->>'meio',
    item->>'meiocompleto',
    item->>'motivo_cancelamento',
    item->>'nomeClasse',
    item->>'nomeOrgao',
    (item->>'numeroComunicacao')::integer,
    item->>'numero_processo',
    item->>'numeroprocessocommascara',
    (item->>'orgao_id')::bigint,
    item->>'siglaTribunal',
    item->>'status',
    item->>'texto',
    item->>'tipoComunicacao',
    item->>'tipoDocumento'
FROM pubs_staging,
     jsonb_array_elements(data->'items') AS item
ON CONFLICT DO NOTHING;

-- 3. Inserir advogados distintos
INSERT INTO advogado (id, nome, numero_oab, uf_oab)
SELECT DISTINCT
    (da->'advogado'->>'id')::bigint,
    da->'advogado'->>'nome',
    da->'advogado'->>'numero_oab',
    da->'advogado'->>'uf_oab'
FROM pubs_staging,
     jsonb_array_elements(data->'items') AS item,
     jsonb_array_elements(item->'destinatarioadvogados') AS da
WHERE da->'advogado' IS NOT NULL
ON CONFLICT DO NOTHING;

-- 4. Inserir tabela de relacionamento entre publicacao e advogado
INSERT INTO destinatario_advogado (id, publicacao_id, advogado_id, created_at, updated_at)
SELECT
    (da->>'id')::bigint,
    (da->>'publicacao_id')::bigint,
    (da->'advogado'->>'id')::bigint,
    (da->>'created_at')::timestamp,
    (da->>'updated_at')::timestamp
FROM pubs_staging,
     jsonb_array_elements(data->'items') AS item,
     jsonb_array_elements(item->'destinatarioadvogados') AS da
ON CONFLICT DO NOTHING;

-- 5. Inserir destinatarios
INSERT INTO destinatario (publicacao_id, nome, polo)
SELECT
    (d->>'publicacao_id')::bigint,
    d->>'nome',
    d->>'polo'
FROM pubs_staging,
     jsonb_array_elements(data->'items') AS item,
     jsonb_array_elements(item->'destinatarios') AS d
ON CONFLICT DO NOTHING; 