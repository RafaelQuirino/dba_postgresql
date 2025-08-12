# 📄 Guia de Acesso de Usuários

Este documento descreve as **roles** (papéis) criadas no banco de dados e os **perfis de acesso** concedidos a cada uma, considerando o schema `analytics`.

---

## 1. Visão Geral

Foram criados diferentes perfis de usuários para controlar o acesso às informações de acordo com o tipo de análise ou necessidade operacional.

- **`analyst_*`** — Perfis de leitura (read-only) restritos a um ou mais tipos de produção.
- **`analyst_all`** — Perfil de leitura com acesso a todas as tabelas do schema `analytics`.
- **`data_scientist`** — Perfil com permissões de leitura e escrita (CRUD) em todas as tabelas do schema `analytics`.

---

## 2. Perfis e Permissões

### 2.1 `analyst_movies`
- **Acesso**: Leitura apenas de filmes.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT` na tabela `analytics.movies`.

---

### 2.2 `analyst_tv`
- **Acesso**: Leitura apenas de séries de TV.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT` na tabela `analytics.tv_shows`.

---

### 2.3 `analyst_games`
- **Acesso**: Leitura apenas de jogos.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT` na tabela `analytics.video_games`.

---

### 2.4 `analyst_docs`
- **Acesso**: Leitura apenas de documentários.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT` na tabela `analytics.documentaries`.

---

### 2.5 `analyst_all`
- **Acesso**: Leitura de todas as tabelas no schema `analytics`.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT` em todas as tabelas existentes no schema.
  - `ALTER DEFAULT PRIVILEGES` garante que qualquer nova tabela criada no schema também terá permissão de leitura.

---

### 2.6 `data_scientist`
- **Acesso**: Total (CRUD) em todas as tabelas do schema `analytics`.
- **Permissões**:
  - `USAGE` no schema `analytics`.
  - `SELECT`, `INSERT`, `UPDATE`, `DELETE` em todas as tabelas existentes no schema.
  - `ALTER DEFAULT PRIVILEGES` garante que novas tabelas também receberão estas permissões automaticamente.

---

## 3. Observações Importantes
	•	Caso novas tabelas sejam adicionadas ao schema analytics, as permissões serão aplicadas automaticamente aos usuários analyst_all e data_scientist graças ao uso de ALTER DEFAULT PRIVILEGES.