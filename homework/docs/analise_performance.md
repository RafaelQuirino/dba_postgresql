## Estratégias de otimização de consultas

Detalhamento da Estratégia
Particionamento por Intervalo (RANGE):
A instrução PARTITION BY RANGE (ano_producao) define que a tabela analytics.movies será dividida em partições com base nos valores da coluna ano_producao. Assim, os dados podem ser agrupados de forma lógica em intervalos sequenciais, como décadas.

Partições por Década:
As tabelas movies_1980s, movies_1990s, movies_2000s, movies_2010s e movies_2020s são as partições filhas que armazenam os dados de movies.

Partição Padrão (DEFAULT):
A tabela analytics.movies_others é uma partição DEFAULT. Isso significa que ela irá armazenar qualquer registro inserido na tabela analytics.movies que não se enquadre em nenhuma das partições de década definidas.

## Recomendações de índices

```sql
CREATE INDEX idx_nome_pessoa ON raw_data.pessoa (nome); -- indice para nome
CREATE INDEX idx_equipe_producao ON raw_data.equipe(producaoID); -- indice para buscar equipe pela producaoID
CREATE INDEX idx_equipe_papel_producao ON raw_data.equipe(papel, producaoID); -- indice para buscar equipe por papel e producao
CREATE INDEX idx_producao_ano ON raw_data.producao(ano_producao); -- indice para buscar ano de producao
CREATE INDEX idx_producao_tipo_ano ON raw_data.producao(tipo_ID, ano_producao); -- indice para buscar tipo e ano de producao

CREATE INDEX idx_movies_nome_pessoa ON analytics.movies(nome_pessoa);
CREATE INDEX idx_movies_titulo ON analytics.movies(titulo);
CREATE INDEX idx_tv_shows_nome_pessoa ON analytics.tv_shows(nome_pessoa);
CREATE INDEX idx_tv_shows_ano ON analytics.tv_shows(ano_producao);
CREATE INDEX idx_documentaries_nome_pessoa ON analytics.documentaries(nome_pessoa);
```


