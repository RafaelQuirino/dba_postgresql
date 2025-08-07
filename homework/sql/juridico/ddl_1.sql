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
