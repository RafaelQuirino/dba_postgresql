# 📄 Documentação do Schema de Banco de Dados

## Visão Geral

O banco de dados é organizado em dois schemas principais:

- **`raw_data`** — Armazena os dados brutos extraídos de fontes originais.
- **`analytics`** — Armazena dados transformados, organizados por tipo de produção, e informações analíticas.

---

## Schema: `raw_data`

### 1. `producoes`
| Coluna       | Tipo         | Restrição         | Descrição |
|--------------|--------------|-------------------|-----------|
| `producao_id`| `INT`        | **PK**            | Identificador único da produção. |
| `titulo`     | `VARCHAR(255)` | NOT NULL        | Título da produção. |
| `ano`        | `INT`        | NOT NULL          | Ano de lançamento da produção. |
| `tipo_id`    | `INT`        | NOT NULL          | Código do tipo de produção (mapeado para `analytics.production_types`). |

**Índices:**
- `idx_producoes_tipo_id` — Acelera consultas filtrando por `tipo_id`.

---

### 2. `pessoas`
| Coluna       | Tipo         | Restrição         | Descrição |
|--------------|--------------|-------------------|-----------|
| `pessoa_id`  | `INT`        | **PK**            | Identificador único da pessoa. |
| `nome`       | `VARCHAR(255)` | NOT NULL        | Nome da pessoa. |

---

### 3. `equipes`
| Coluna       | Tipo         | Restrição         | Descrição |
|--------------|--------------|-------------------|-----------|
| `pessoa_id`  | `INT`        | **PK**, FK → `pessoas(pessoa_id)` | Identificador da pessoa. |
| `producao_id`| `INT`        | **PK**, FK → `producoes(producao_id)` | Identificador da produção. |
| `papel`      | `TEXT`       | NOT NULL          | Papel exercido na produção (ex.: diretor, ator). |

---

## Schema: `analytics`

### 1. `production_types`
| Coluna       | Tipo           | Restrição         | Descrição |
|--------------|----------------|-------------------|-----------|
| `tipo_id`    | `INT`          | **PK**            | Código único do tipo de produção. |
| `descricao`  | `VARCHAR(100)` | NOT NULL          | Descrição do tipo (ex.: Movie, TV Show). |

---

### 2. Tabelas por tipo de produção
Cada tabela armazena produções de um tipo específico, todas com as mesmas colunas:

| Coluna  | Tipo           | Restrição  | Descrição |
|---------|----------------|------------|-----------|
| `*_id`  | `INT`          | **PK**     | Identificador da produção. |
| `title` | `VARCHAR(255)` | NOT NULL   | Título da produção. |
| `year`  | `INT`          | NOT NULL   | Ano da produção. |

**Tabelas:**
- `movies`
- `tv_shows`
- `video_games`
- `documentaries`
- `short_films`
- `music_videos`
- `theater_productions`
- `web_series`
- `animations`

---

### 3. `persons`
| Coluna     | Tipo           | Restrição | Descrição |
|------------|----------------|-----------|-----------|
| `person_id`| `INT`          | **PK**    | Identificador único da pessoa. |
| `name`     | `VARCHAR(255)` | NOT NULL  | Nome da pessoa. |

---

### 4. `crew`
Armazena a relação entre pessoas e produções, com o papel exercido.

| Coluna           | Tipo          | Restrição |
|------------------|---------------|-----------|
| `person_id`      | `INT`         | **PK**, FK → `persons(person_id)` |
| `production_type`| `VARCHAR(50)` | **PK**, CHECK (`IN movie, tv_show, video_game, documentary, short_film, music_video, theater, web_series, animation`) |
| `production_id`  | `INT`         | **PK**    |
| `job`            | `TEXT`        | **PK**    | Papel/função exercida. |

**Índices:**
- `idx_crew_production` — (`production_type`, `production_id`)
- `idx_crew_job` — (`job`)
- `idx_crew_person` — (`person_id`)

---

## 🔄 Fluxo de Carga de Dados

1. **Seed de tipos de produção** (`analytics.production_types`):
   - IDs fixos como 1=Movie, 2=TV Show, etc.

2. **População de tabelas de produções**:
   - Dados migrados de `raw_data.producoes` para a tabela correspondente no `analytics` conforme `tipo_id`.

3. **População de `persons`**:
   - Dados de `raw_data.pessoas`.

4. **População de `crew`**:
   - Dados de `raw_data.equipes` relacionados a `analytics.persons` e `analytics.production_types`.

---

## Observações
- Produções com `ano = 0` representam ano desconhecido e podem ser filtradas em análises temporais.
- As chaves compostas em `crew` e `equipes` garantem unicidade por pessoa+produção+papel.
- O relacionamento `crew` utiliza `production_type` para mapear a tabela correta no `analytics`.