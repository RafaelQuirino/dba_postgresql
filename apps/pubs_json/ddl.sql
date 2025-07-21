-- DDL para a estrutura do arquivo de publicações no formato json 

CREATE TABLE IF NOT EXISTS publicacao (
    id BIGINT PRIMARY KEY,
    md5 TEXT,
    ativo BOOLEAN,
    codigo_classe TEXT,
    data_disponibilizacao DATE,
    datadisponibilizacao TEXT,
    dataenvio DATE,
    hash TEXT,
    link TEXT,
    meio TEXT,
    meiocompleto TEXT,
    motivo_cancelamento TEXT,
    nome_classe TEXT,
    nome_orgao TEXT,
    numero_comunicacao INTEGER,
    numero_processo TEXT,
    numeroprocessocommascara TEXT,
    orgao_id BIGINT,
    sigla_tribunal TEXT,
    status TEXT,
    texto TEXT,
    tipo_comunicacao TEXT,
    tipo_documento TEXT
);

CREATE TABLE IF NOT EXISTS advogado (
    id BIGINT PRIMARY KEY,
    nome TEXT,
    numero_oab TEXT,
    uf_oab TEXT
);

CREATE TABLE IF NOT EXISTS destinatario_advogado (
    id BIGINT PRIMARY KEY,
    publicacao_id BIGINT REFERENCES publicacao(id),
    advogado_id BIGINT REFERENCES advogado(id),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS destinatario (
    id SERIAL PRIMARY KEY,
    publicacao_id BIGINT REFERENCES publicacao(id),
    nome TEXT,
    polo TEXT
);

CREATE TABLE IF NOT EXISTS pubs_metadata (
    id SERIAL PRIMARY KEY,
    tribunal TEXT,
    md5 TEXT
);

CREATE TABLE IF NOT EXISTS pubs_staging (
    data JSONB
); 