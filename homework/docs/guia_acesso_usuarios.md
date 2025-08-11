# Guia de Acesso de Usuários - CineTech Studios

Este documento descreve os usuários criados no banco `cinetech_productions`, suas permissões e escopo de acesso.

---

## Usuários Criados

| Usuário           | Senha | Finalidade                                 |
|------------------|--------|---------------------------------------------|
| analyst_movies    | SenhaForte@1    | Consultar apenas produções do tipo filme    |
| analyst_tv        | SenhaForte@2    | Consultar apenas produções de TV            |
| analyst_games     | SenhaForte@3    | Consultar apenas videogames                 |
| analyst_docs      | SenhaForte@4    | Consultar apenas documentários              |
| analyst_all       | SenhaForte@5    | Acesso de leitura a todas as produções      |
| data_scientist    | SenhaForte@6    | Leitura e escrita no schema `analytics`     |

---

## Matriz de Permissões

| Usuário           | SELECT | INSERT | UPDATE | DELETE | Tabelas com Acesso          |
|------------------|--------|--------|--------|--------|-----------------------------|
| analyst_movies    | ✅     | ❌     | ❌     | ❌     | `analytics.movies`          |
| analyst_tv        | ✅     | ❌     | ❌     | ❌     | `analytics.tv_shows`        |
| analyst_games     | ✅     | ❌     | ❌     | ❌     | `analytics.video_games`     |
| analyst_docs      | ✅     | ❌     | ❌     | ❌     | `analytics.documentaries`   |
| analyst_all       | ✅     | ❌     | ❌     | ❌     | Todas do schema `analytics` |
| data_scientist    | ✅     | ✅     | ✅     | ✅     | Todas do schema `analytics` |

