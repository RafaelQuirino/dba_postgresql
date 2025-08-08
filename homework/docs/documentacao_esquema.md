- DER (Diagrama Entidade Relacionamento)

![DER](Diagrama Entidade Relacionamento.jpg "DER")

- Definições de tabelas com restrições

Como representado no script `sql/01_criacao_banco.sql`, as tabelas com restrições são:

| Tabela     | Restrição usada                      |
|------------|--------------------------------------|
| `producao` | PRIMARY KEY                          |
| `pessoa`   | PRIMARY KEY                          |
| `equipe`   | PRIMARY KEY e FOREIGN KEY            |

```
CREATE TABLE raw_data.producao (
    producaoID INT PRIMARY KEY,
    titulo VARCHAR(255),
    ano_producao INT,
    tipo_ID INT
);

CREATE TABLE raw_data.pessoa (
    pessoaID INT PRIMARY KEY,
    nome VARCHAR(255)
);

CREATE TABLE raw_data.equipe (
    pessoaID INT,
    producaoID INT,
    papel TEXT,
    PRIMARY KEY (pessoaID, producaoID),
    FOREIGN KEY (pessoaID) REFERENCES raw_data.pessoa(pessoaID),
    FOREIGN KEY (producaoID) REFERENCES raw_data.producao(producaoID)
);
```
- Eatratégias de indexação

CREATE INDEX idx_nome_pessoa ON raw_data.pessoa (nome); -- indice para nome
CREATE INDEX idx_equipe_producao ON raw_data.equipe(producaoID); -- indice para buscar equipe pela producaoID
CREATE INDEX idx_equipe_papel_producao ON raw_data.equipe(papel, producaoID); -- indice para buscar equipe por papel e producao
CREATE INDEX idx_producao_ano ON raw_data.producao(ano_producao); -- indice para buscar ano de producao
CREATE INDEX idx_producao_tipo_ano ON raw_data.producao(tipo_ID, ano_producao); -- indice para buscar tipo e ano de producao

