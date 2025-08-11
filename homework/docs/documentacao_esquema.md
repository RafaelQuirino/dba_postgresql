# Documentação do Esquema do Banco de Dados - CineTech Studios

## Objetivo

Descrever a estrutura lógica do banco de dados `cinetech`, suas tabelas, esquemas, e estratégias de indexação, como foi solicitado no trabalho prático de DBA.

---

## Schemas

### 1. `raw_data`

Contém os dados brutos ingeridos a partir dos arquivos `producao.txt`, `pessoa.txt` e `equipe.txt`.

#### Tabelas

- **producao(id_producao, titulo, ano_producao, tipo_id)**
  - PK: `id_producao`
  - Descreve cada produção artística.

- **pessoa(id_pessoa, nome)**
  - PK: `id_pessoa`
  - Lista de pessoas envolvidas em produções.

- **equipe(id_pessoa, id_producao, papel)**
  - PK: (`id_pessoa`, `id_producao`)
  - FK: `id_pessoa` → pessoa
  - FK: `id_producao` → producao
  - Representa o relacionamento N:N entre pessoa e produção.

---

### 2. `analytics`

Contém tabelas derivadas segmentadas por tipo de produção, otimizadas para análise.

#### Tabelas segmentadas

- **movies**
- **tv_shows**
- **documentaries**
- **short_films**
- **music_videos**
- **video_games**
- **animations**
- **web_series**, **theater_productions**: placeholders (sem dados)

#### Views Analíticas

- **production_summary**
- **top_actors_by_type**
- **yearly_production_trends**
- **crew_analysis**

---

## Chaves e Restrições

| Tabela        | Chave Primária         | Chaves Estrangeiras                          |
|---------------|-------------------------|-----------------------------------------------|
| producao      | id_producao             | —                                             |
| pessoa        | id_pessoa               | —                                             |
| equipe        | (id_pessoa, id_producao)| id_pessoa → pessoa, id_producao → producao   

---

## Estratégias de Indexação

| Tabela                | Coluna(s) Indexada(s)     | Motivo                                   |
|----------------------|----------------------------|------------------------------------------|
| producao             | ano, tipo_id               | Filtros e agrupamentos frequentes        |
| equipe               | id_pessoa, id_producao     | Joins e contagens                        |
| equipe               | LOWER(papel)               | Análise por papel da equipe              |
| analytics.movies     | ano                        | Tendência anual de filmes                |
| analytics.tv_shows   | ano                        | Tendência anual de séries                |
| analytics.*          | ano                        | Índices replicados nas tabelas analíticas|

---

## Observações

- Os dados foram ingeridos a partir de arquivos `.txt` com código Python.
- Foram criados vários usuários para cada especialização.
- Todas as views foram criadas no próprio schema `analytics`, facilitando acesso por perfis especializados.