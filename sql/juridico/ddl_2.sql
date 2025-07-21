-- Tabela de publicações
CREATE TABLE publicacoes (
    id SERIAL PRIMARY KEY,
    texto TEXT NOT NULL,
    processo TEXT,
    juizado TEXT
);

-- Tabela de advogados (relação N para N)
CREATE TABLE advogados (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    oab TEXT NOT NULL UNIQUE
);

-- Tabela de relação entre publicações e advogados
CREATE TABLE publicacoes_advogados (
    id_publicacao INTEGER NOT NULL REFERENCES publicacoes(id) ON DELETE CASCADE,
    id_advogado INTEGER NOT NULL REFERENCES advogados(id) ON DELETE CASCADE,
    PRIMARY KEY (id_publicacao, id_advogado)
);

-- Tabela de juízes (relação 1 para N)
CREATE TABLE juizes (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE
);

-- Tabela de relação entre publicações e juízes
CREATE TABLE publicacoes_juizes (
    id_publicacao INTEGER NOT NULL REFERENCES publicacoes(id) ON DELETE CASCADE,
    id_juiz INTEGER NOT NULL REFERENCES juizes(id) ON DELETE CASCADE,
    PRIMARY KEY (id_publicacao, id_juiz)
);

