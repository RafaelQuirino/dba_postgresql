Com certeza. O modelo de documentação é excelente. Criei um guia de acesso de usuários alinhado exatamente com o que implementamos e validamos juntos, utilizando os nomes de roles, senhas e permissões que definimos.

Este documento pode ser salvo como `guia_acesso_usuarios.md` na sua pasta `docs/`.

-----

# Guia de Acesso de Usuários - CineTech Studios

Este documento descreve os usuários criados no banco de dados `cinetech_productions`, detalhando suas respectivas permissões, escopo de acesso e como validar a segurança implementada.

-----

## Usuários Criados

| Usuário | Senha de Exemplo | Finalidade |
| :--- | :--- | :--- |
| `analyst_movies` | `senha_forte_movies` | Consultar **apenas** produções do tipo filme. |
| `analyst_tv` | `senha_forte_tv` | Consultar **apenas** produções do tipo Série de TV. |
| `analyst_games` | `senha_forte_games` | Consultar **apenas** produções do tipo Videogame. |
| `analyst_docs` | `senha_forte_docs` | Consultar **apenas** produções do tipo Documentário. |
| `analyst_all` | `senha_forte_all` | Acesso de **leitura a todas** as tabelas de analytics. |
| `data_scientist` | `senha_forte_ds` | Acesso de **leitura e escrita** no schema `analytics`. |

-----

## Matriz de Permissões

A tabela abaixo resume os privilégios concedidos a cada role no schema `analytics`.

| Usuário | `SELECT` | `INSERT` | `UPDATE` | `DELETE` | Tabelas com Acesso |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `analyst_movies` | ✅ | ❌ | ❌ | ❌ | `analytics.movies` |
| `analyst_tv` | ✅ | ❌ | ❌ | ❌ | `analytics.tv_shows` |
| `analyst_games` | ✅ | ❌ | ❌ | ❌ | `analytics.video_games` |
| `analyst_docs` | ✅ | ❌ | ❌ | ❌ | `analytics.documentaries` |
| `analyst_all` | ✅ | ❌ | ❌ | ❌ | Todas do schema `analytics` |
| `data_scientist` | ✅ | ✅ | ✅ | ✅ | Todas do schema `analytics` |

-----

## Comandos de Criação e Permissões

Os comandos de criação dos usuários e concessão de permissões foram executados diretamente na sessão `psql` durante a **Fase 3** do projeto. Os principais comandos utilizados foram:

  * `CREATE ROLE ... LOGIN PASSWORD ...`
  * `GRANT USAGE ON SCHEMA analytics TO ...`
  * `GRANT SELECT ON TABLE ... TO ...`
  * `GRANT SELECT ON ALL TABLES IN SCHEMA ... TO ...`
  * `GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ... TO ...`

-----

## Guia de Testes de Permissão

É possível validar o controle de acesso de forma prática usando o comando `SET ROLE` na sessão `psql`.

### 1\. Testar um Analista com Acesso Restrito

Este teste confirma que o `analyst_movies` pode ver a tabela de filmes, mas é bloqueado ao tentar acessar outras tabelas.

**Passo 1: Assumir o papel do usuário**

```sql
SET ROLE analyst_movies;
```

**Passo 2: Executar uma consulta permitida (deve funcionar)**

```sql
SELECT * FROM analytics.movies LIMIT 5;
```

*Tire um print da tela aqui para sua documentação: `![Consulta permitida para analyst_movies](image.png)`*

**Passo 3: Executar uma consulta proibida (deve falhar)**

```sql
SELECT * FROM analytics.tv_shows LIMIT 5;
```

*Tire um print da tela aqui mostrando o erro "permission denied": `![Consulta proibida para analyst_movies](image-1.png)`*

**Passo 4: Retornar ao seu usuário original**

```sql
RESET ROLE;
```

### 2\. Testar o Data Scientist (Leitura e Escrita)

Este teste confirma que o `data_scientist` pode ler e também realizar operações de escrita, como `UPDATE`.

**Passo 1: Assumir o papel do usuário**

```sql
SET ROLE data_scientist;
```

**Passo 2: Testar a permissão de escrita de forma segura**
Usamos uma transação com `ROLLBACK` para testar a permissão de `UPDATE` sem alterar os dados permanentemente.

```sql
BEGIN;

-- Tenta realizar um update
UPDATE analytics.movies
SET titulo = titulo || ' [TESTE DE ESCRITA]'
WHERE producao_id = 33755; -- Usando um ID de exemplo

-- Verifica a alteração dentro da transação
SELECT titulo FROM analytics.movies WHERE producao_id = 33755;

-- Desfaz a alteração
ROLLBACK;
```

*Tire um print da tela aqui mostrando o resultado da transação: `![Teste de escrita com data_scientist](image-2.png)`*

**Passo 3: Confirmar que a alteração foi desfeita**
Execute a consulta novamente para garantir que o título não contém o texto de teste.

```sql
SELECT titulo FROM analytics.movies WHERE producao_id = 33755;
```

*Tire um print da tela aqui mostrando que o dado não foi alterado: `![Confirmação do rollback](image-3.png)`*

> **Conclusão do Teste:** A transação confirma que o usuário `data_scientist` tem permissão de escrita, e o `ROLLBACK` garante que o banco de dados permaneceu íntegro.

**Passo 4: Retornar ao seu usuário original**

```sql
RESET ROLE;
```