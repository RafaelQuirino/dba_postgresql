# Documentação do Esquema do Banco de Dados

**Versão:** 1.0
**Data:** 11 de agosto de 2025

Este documento detalha a estrutura do banco de dados do projeto, desde os dados brutos até as tabelas otimizadas para análise.

---

## 1. Arquitetura em Camadas

O Data Warehouse é organizado em três camadas lógicas:

* **🥉 Camada Bronze (`raw_data`):** Contém os dados brutos, no seu estado original. É a fonte de verdade para todas as transformações.
* **🥈 Camada Silver (`trusted_data`):** Consiste em views que limpam, enriquecem e padronizam os dados da camada Bronze. É aqui que as regras de negócio são aplicadas.
* **🥇 Camada Gold (`analytics`):** Contém tabelas físicas (materializadas) e otimizadas para consulta, prontas para serem consumidas por ferramentas de BI e análises.

---

## 2. Dicionário de Dados e Relacionamentos

### Camada Bronze (`raw_data`)

* **`producao`**: Tabela principal com informações sobre cada produção.
    * `producaoID (PK)`: Chave primária.
* **`pessoa`**: Tabela com informações sobre cada pessoa da equipe.
    * `pessoaID (PK)`: Chave primária.
* **`equipe`**: Tabela de associação que implementa o relacionamento **Muitos-para-Muitos** entre `producao` e `pessoa`.

![Diagrama Entidade-Relacionamento do Projeto](Images\DBA_trabalho.drawio.png)

### Camada Silver (`trusted_data`)

* **`vw_producoes`**: View que enriquece os dados de `producao`, traduzindo `tipo_ID` para um texto legível (ex: `Filme`, `Série de TV`) e tratando categorias desconhecidas.
* **`vw_equipe_completa`**: View que une `producao`, `equipe` e `pessoa`, tratando valores nulos no campo `papel` para garantir a qualidade dos dados.

### Camada Gold (`analytics`)

Nesta camada, os dados são separados em **Data Marts** especializados por tipo de produção.

* **`movies`**, **`tv_shows`**, **`documentaries`**, **`video_games`**, **`short_films`**, **`theater_productions`**, **`adult_films`**, **`uncategorized`**: Tabelas físicas que contêm apenas produções de um tipo específico, otimizadas para consultas rápidas.

    * **Colunas Padrão:** `producaoID (PK)`, `titulo`, `ano_producao`. Para facilitar a visualização por parte do usuário foi renomeada as colunas de `producaoID` para `id` e de `ano_producao` para `ano`.

---

## 3. Estratégias de Indexação

Para garantir a performance das consultas na camada `analytics`, foram criados os seguintes índices em **todas** as tabelas (ex: `movies`, `tv_shows`, `documentaries`, `video_games`, `short_films`, `theater_productions`, `adult_films`, `uncategorized`):

| Coluna Indexada | Tipo de Índice | Propósito                                                  |
| :-------------- | :------------- | :--------------------------------------------------------- |
| `ano`           |     `INDEX`    | Garante unicidade e acelera buscas e joins pelo ID.        |
| `titulo`        |     `INDEX`    | Garante unicidade e acelera buscas e joins pelo ID.        |