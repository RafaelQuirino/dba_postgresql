## 📋 Visão Geral
Entre numa trilha sobre:
- Projeto e criação de esquemas de banco de dados
- Ingestão de dados reais numa base de dados chamada **CineTech Studios**

## 🏗️ Fase 1: Projeto e Implementação do Banco de Dados

Como parte do projeto de um banco de dados foi criado o Diagrama Entidade-Relacionamento (DER), que permite a visualização de como as entidades e
tabelas estão relacionadas.

A base possui um esquema chamado `raw_data` com três tabelas:

1. **`producao`** - Armazenar todos os dados de produção
2. **`pessoa`** - Armazenar todos os dados de pessoas
3. **`equipe`** - Armazenar todos os relacionamentos de equipe/elenco

Cada tabela foi criada com tipos de dados apropriados, implementação de chaves primárias e estrangeiras.

Para a **ingestão dos dados** foram criados scripts python com mensagens claras e tratamento de erros adequados. Ao fazer a conexão com o BD, por exemplo:

✅ Conectado ao banco com sucesso.

Caso encontrado um erro:
| ⚠️ Erro de conversão: 447145##Traversées 11###2004##1
| -> invalid literal for int() with base 10: '#2004'

Para executar o script você precisa adicionar à pasta raiz onde estiver o script a fonte de dados em **.txt**.


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