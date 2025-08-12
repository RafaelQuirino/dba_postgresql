## **Guia de Acesso de Usuários (RBAC) - Banco de Dados `cinetech_productions`** 🔑

**Autor:** Seu DBA
**Data:** 11 de agosto de 2025
**Assunto:** Documentação oficial sobre a estrutura de permissões no banco de dados.

### **1. Introdução e Filosofia de Acesso**

Este documento detalha o funcionamento do script de gerenciamento de acesso ao banco de dados `cinetech_productions`. A nossa estratégia é baseada em **RBAC (Role-Based Access Control)**, ou Controle de Acesso Baseado em Funções.

Pense nisso da seguinte forma: em vez de dar permissões diretamente a cada usuário, nós criamos "crachás de acesso" (que no PostgreSQL são chamados de `Roles` ou `Groups`). Cada crachá possui um conjunto específico de permissões. Para dar acesso a um usuário, simplesmente entregamos a ele os crachás apropriados.

**Vantagens desta abordagem:**
* **Escalabilidade:** Para dar a mesma permissão a 100 analistas, modificamos apenas um crachá, em vez de 100 usuários.
* **Segurança:** As permissões são granulares e auditáveis. É fácil ver quem tem acesso a quê.
* **Manutenção Simplificada:** Contratar ou desligar um funcionário se resume a criar/apagar um usuário e atribuir/revogar seus crachás.

O script foi projetado para ser **idempotente**, um termo que significa que ele pode ser executado várias vezes e o resultado final será sempre o mesmo, sem gerar erros. Isso o torna "à prova de balas" para implantação e atualizações.

---

### **2. A Estrutura de Permissões**

A lógica do script é dividida em partes claras, que constroem a segurança em camadas.

#### **Camada 1: Os "Crachás" — Roles de Grupo (Seção A)**

Primeiro, criamos um conjunto de `Roles` que funcionam como modelos ou grupos de permissão. Nenhuma delas é um usuário real (não possuem a permissão `LOGIN`).

* `analyst_base`: O crachá fundamental. Fornece o acesso mais básico necessário para qualquer analista se conectar ao banco e "ver" os schemas principais.
* `*_reader` (ex: `movies_reader`, `tv_shows_reader`): Crachás específicos para cada categoria de produção. Cada um dá permissão de **leitura (`SELECT`)** a uma única tabela no schema `analytics`.
* `all_analytics_reader`: Um crachá poderoso que concede permissão de **leitura (`SELECT`)** em **todas** as tabelas dos schemas `trusted_data` e `analytics`.
* `data_science_full_access`: O crachá mais privilegiado para a área de análise. Concede permissão de **leitura e escrita (`SELECT`, `INSERT`, `UPDATE`, `DELETE`)** no schema `analytics`. Também permite a criação de novas tabelas nesse schema.

#### **Camada 2: Atribuindo Poderes aos Crachás (Seções B e C)**

Uma vez que os crachás existem, nós definimos o que cada um pode fazer.

* **`analyst_base`**:
    * `CONNECT` ao banco de dados `cinetech_productions`. (Pode "entrar no prédio").
    * `USAGE` nos schemas `trusted_data` e `analytics`. (Pode "andar pelos corredores" desses departamentos).
* **Crachás `*_reader`**:
    * `SELECT` na tabela correspondente (ex: `movies_reader` pode ler `analytics.movies`). (Pode "ler os arquivos" de uma sala específica).
* **`all_analytics_reader`**:
    * `SELECT` em **todas** as tabelas presentes e futuras dos schemas `trusted_data` e `analytics`. (Pode "ler todos os arquivos" de ambos os departamentos).
* **`data_science_full_access`**:
    * `USAGE` e `CREATE` no schema `analytics`. (Pode "usar e construir salas novas" no departamento de Analytics).
    * Permissões completas (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) em todas as tabelas e sequências do schema `analytics`. (Pode "ler, criar, editar e apagar qualquer arquivo" nesse departamento).

A **Seção C (`ALTER DEFAULT PRIVILEGES`)** é crucial: ela garante que qualquer **tabela nova** criada nos schemas `trusted_data` ou `analytics` automaticamente receba as permissões corretas para os crachás `all_analytics_reader` e `data_science_full_access`. Isso evita que o acesso "quebre" no futuro.

---

### **3. Usuários Finais e Seus Perfis (Seções D e E)**

Finalmente, criamos os usuários que de fato acessarão o banco e entregamos a eles seus crachás. A combinação de crachás define o perfil de acesso de cada um.

| Usuário Final (`ROLE`)      | Crachás Atribuídos (`GROUPS`)        | Capacidades Resultantes                                                                                                 |
| :-------------------------- | :----------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| `analyst_all`               | `analyst_base`, `all_analytics_reader`       | **Analista Geral:** Pode se conectar e ler **todas** as tabelas de `trusted_data` e `analytics`.                          |
| `data_scientist`            | `analyst_base`, `data_science_full_access`   | **Cientista de Dados:** Pode se conectar, ler, criar, modificar e apagar **tudo** no schema `analytics`.                |
| `analyst_movies`            | `analyst_base`, `movies_reader`              | **Analista de Filmes:** Pode se conectar e ler **apenas** a tabela `analytics.movies`.                                  |
| `analyst_tv`                | `analyst_base`, `tv_shows_reader`            | **Analista de TV:** Pode se conectar e ler **apenas** a tabela `analytics.tv_shows`.                                    |
| `analyst_games`             | `analyst_base`, `games_reader`               | **Analista de Games:** Pode se conectar e ler **apenas** a tabela `analytics.video_games`.                              |
| `analyst_docs`              | `analyst_base`, `docs_reader`                | **Analista de Documentários:** Pode se conectar e ler **apenas** a tabela `analytics.documentaries`.                    |
| `analyst_shorts`            | `analyst_base`, `short_films_reader`         | **Analista de Curtas:** Pode se conectar e ler **apenas** a tabela `analytics.short_films`.                             |
| `analyst_theater`           | `analyst_base`, `theater_prod_reader`        | **Analista de Teatro:** Pode se conectar e ler **apenas** a tabela `analytics.theater_productions`.                     |
| `analyst_adults`            | `analyst_base`, `adult_films_reader`         | **Analista de Filmes Adultos:** Pode se conectar e ler **apenas** a tabela `analytics.adult_films`.                     |
| `analyst_uncategorized`     | `analyst_base`, `uncategorized_reader`       | **Analista (Sem Categoria):** Pode se conectar e ler **apenas** a tabela `analytics.uncategorized`.                     |

> **⚠️ AVISO DE SEGURANÇA:** As senhas no script (`CREATE ROLE ... PASSWORD ...`) são fornecidas apenas para fins de exemplo. Em um ambiente de produção real, as senhas devem ser gerenciadas por um sistema seguro (cofre de senhas) ou substituídas por métodos de autenticação mais robustos.

---

### **4. O Mecanismo "À Prova de Balas" (Seção de Limpeza)**

A primeira seção do script, **`SEÇÃO DE LIMPEZA GERAL`**, é o que o torna idempotente. Antes de criar qualquer coisa, ele desmonta a estrutura existente na ordem inversa e segura para evitar erros de dependência:

1.  **Apaga os Usuários Finais:** Remove as contas `analyst_*` que possuem a permissão `LOGIN`.
2.  **Revoga as Permissões dos Grupos:** Remove as permissões dos crachás (`analyst_base`, etc.).
3.  **Apaga os Grupos:** Por último, remove os próprios crachás, que agora estão livres de dependências.

O uso de `DROP ROLE IF EXISTS` e blocos `DO $$... IF EXISTS ...$$` garante que o script não falhe se um objeto que ele tenta apagar já não existir. Isso permite que o script seja executado em um banco de dados novo ou em um já configurado, sempre garantindo que o estado final seja o correto. 🛡️

### **5. Testes**

![Teste1_analyst_movies](Images\Teste1_analyst_movies.png)

![Teste2_analyst_all](Images\Teste2_analyst_all.png)

![Teste3_data_scientist](Images\Teste3_data_scientist.png)