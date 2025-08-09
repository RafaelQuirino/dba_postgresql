# 📚 Documentação — Esquema Banco de Dados CineTech Studios

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)

---

## 🎯 Objetivo
Documentar os schemas do banco de dados tem como objetivo definir claramente o propósito, escopo e responsabilidades de cada um, listar seus objetos (tabelas, views, funções), contratos de entrada/saída, regras de qualidade, permissões e políticas de acesso, além de convenções de nomenclatura e dependências; isso padroniza o uso, facilita onboarding e auditorias, orienta otimizações de performance e torna mais segura a evolução do modelo e das integrações.

## 🗃️ Schemas
### 1) raw_data
Possui os dados brutos ingeridos a partir dos arquivos:
    - ```producao.txt```
    - ```pessoa.txt``` 
    - ```equipe.txt```
**Tabelas:**
- **producao(producaoID, titulo, ano, tipo_id)**

    - PK: ```producaoID```
    - Descreve cada produção artística.

- **pessoa(id_pessoa, nome)**

    - PK: ```pessoaID```
    - Lista de pessoas envolvidas em produções.

- **equipe(id_pessoa, id_producao, papel)**

    - PK: (```pessoaID```, ```producaoID```)
    - FK: ```pessoaID``` → pessoa
    - FK: ```producaoID``` → producao
    - Trata-se de uma tabela associativa, obtida através do relacionamento M:N entre pessoa e produção.

### 2) analytics
Possui tabelas derivadas segmentadas por tipo de produção e otimizadas para análise.
**Tabelas:**
- 🎥 **movies:** tipo_id = 1
- 📺 **tv_shows:** tipo_id = 2
- 🎞️**short_films:** tipo_id = 3
- 🎬**independent_films** tipo_id = 4
- 🎙️**documentaries:** tipo_id = 5
- 🕹️**video_games:** tipo_id = 6
- 📼**episodes:** tipo_id = 7

**Views Analíticas:**
- ```production_summary```
- ```top_actors_by_type```
- ```yearly_production_trends```
- ```crew_analysis```

## 🔑 Chaves e Restrições

| Tabela  | Chave Primária           | Chaves Estrangeiras                                   |
|---------|--------------------------|-------------------------------------------------------|
| producao| producaoID               | —                                                     |
| pessoa  | pessoaID                 | —                                                     |
| equipe  | (pessoaID, producaoID)   | pessoaID → pessoa, producaoID → producao              |

## ⚡ Estratégias de Indexação

| Tabela             | Coluna(s) Indexada(s) | Motivo                                     |
|--------------------|-----------------------|--------------------------------------------|
| producao           | ano, tipo_id          | Filtros e agrupamentos frequentes          |
| equipe             | pessoaID, producaoID  | Joins e contagens                          |
| equipe             | LOWER(papel)          | Análise por papel da equipe                |
| analytics.movies   | ano_producao          | Tendência anual de filmes                  |
| analytics.tv_shows | ano_producao          | Tendência anual de séries                  |
| analytics.*        | ano_producao          | Índices replicados nas tabelas analíticas  |

