## 📋 Visão Geral
Entre numa trilha sobre:
- Projeto e criação de esquemas de banco de dados
- Ingestão de dados reais numa base de dados chamada **CineTech Studios**
- Gerenciamento de usuários
- Criação de views

## 🏗️ Fase 1: Projeto e Implementação do Banco de Dados

A base possui um esquema chamado `raw_data` com três tabelas:

1. **`producao`** - Armazenar todos os dados de produção
2. **`pessoa`** - Armazenar todos os dados de pessoas
3. **`equipe`** - Armazenar todos os relacionamentos de equipe/elenco

Cada tabela foi criada com tipos de dados apropriados, implementação de chaves primárias e estrangeiras.

Para a **ingestão dos dados** foram criados scripts python com mensagens claras e tratamento de erros adequados. Ao fazer a conexão com o BD, por exemplo:
✅ Conectado ao banco com sucesso.
Para executar o script você precisa adicioná-lo à pasta raiz onde estiver o script a fonte de dados em **.txt**.

## 🎨 Fase 2: Projeto do Esquema Analítico

Este projeto cria o schema analytics, com tabelas especializadas para diferentes tipos de produções artísticas. Cada tabela armazena apenas dados do seu tipo específico, com base na estrutura da tabela original Producao. São elas as tabelas incluídas:
1. **movies** - Todas as produções de filmes 
2. **tv_shows** - Todas as produções de séries de TV 
3. **video_games** - Todas as produções de videogames 
4. **documentaries** - Todas as produções de documentários
5. **short_films** - Todas as produções de curtas-metragens 
6. **music_videos** - Todas as produções de clipes de música 
7. **theater_productions** - Todas as produções teatrais 
8. **web_series** - Todas as produções de séries web 
9. **animations** - Todas as produções de animação 

Na estrutura consistente há índices otimizados para consultas frequentes **(ano_producao, nome_pessoa, titulo)** e o **particionamento por décadas** na tabela **movies**.

## 🔐 Fase 3: Gerenciamento de Usuários e Controle de Acesso

Criação de usuários especializados conforme elencado abaixo:
1. analyst_movies - Pode acessar apenas dados relacionados a filmes
2. analyst_tv - Pode acessar apenas dados relacionados a séries de TV
3. analyst_games - Pode acessar apenas dados relacionados a videogames
4. analyst_docs - Pode acessar apenas dados relacionados a documentários
5. analyst_all - Pode acessar todos os dados analíticos (somente leitura)
6. data_scientist - Pode acessar todos os dados com permissões de escrita no esquema analytics

## 📋 Fase 3: Analytics e Relatórios

Criação das seguintes views:
1. production_summary - Estatísticas resumidas por tipo de produção
2. top_actors_by_type - Atores mais ativos por tipo de produção
3. yearly_production_trends - Tendências de produção ao longo do tempo
4. crew_analysis - Análise de papéis e participação da equipe

Criação de consultas para responder às perguntas de negócio:
**1. Qual tipo de produção tem mais produções?**
**2. Quais são os 10 atores mais ativos em todos os tipos de produção?**
**3. Como o número de produções mudou nos últimos 50 anos?**
**4. Quais anos tiveram a maior produção?**
**5. Qual porcentagem de produções tem membros da equipe com papéis específicos?**