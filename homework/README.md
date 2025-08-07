# 📚 CineTech Studios - Guia do Projeto de DBA

## 1. Visão Geral
Neste projeto, você acompanhará toda a jornada do administrador de banco de dados (DBA) da CineTech Studios, uma empresa fictícia. Encontrará o design completo do banco de dados **PostgreSQL**, scripts para ingestão automatizada de dados usando **Python**, configurações detalhadas de controle de acesso para garantir segurança, além de views que exploram o potencial dos dados para análises estratégicas.

| Componentes Incluídos                                                                 |
|---------------------------------------------------------------------------------------|
| - Projeto do banco                                                                    |
| - Ingestão de dados com Python                                                        |
| - Gerenciamento de usuários e controle de acesso                                      |
| - Relatórios e visualizações com views personalizadas                                 |

---

## 2. Estrutura do Schema `raw_data`
O schema `raw_data` reúne as principais tabelas do projeto:
| Tabela     | Descrição                            |
|------------|--------------------------------------|
| `producao` | Dados de produção                    |
| `pessoa`   | Dados pessoais                       |
| `equipe`   | Relações entre produção e equipe     |

Para a ingestão dos dados, são utilizados **scripts em Python** que processam arquivos `.txt`, aplicando tratamento de erros e exibindo mensagens claras de sucesso ou falha.

---

## 3. Estrutura do Schema `analytics`
No schema `analytics`, foram criadas tabelas especializadas para cada tipo de produção artística, facilitando consultas e análises específicas:
| Tabela                 | Tipo de Produção            |
|------------------------|-----------------------------|
| `movies`               | Filmes                      |
| `tv_shows`             | Séries de TV                |
| `video_games`          | Jogos                       |
| `documentaries`        | Documentários               |
| `short_films`          | Curtas                      |
| `music_videos`         | Clipes musicais             |
| `theater_productions`  | Teatro                      |
| `web_series`           | Séries Web                  |
| `animations`           | Animações                   |

Os principais recursos implementados incluem:
- Índices otimizados para colunas como ano_producao, nome_pessoa e titulo para acelerar buscas;
- Particionamento da tabela movies por década, melhorando a performance em consultas históricas.

---

## 4. Controle de Acesso por Usuário
Um dos pontos essenciais para qualquer **DBA** é o **controle de acesso.** Neste projeto, reunimos de forma clara todas as permissões e regras implementadas para garantir segurança e organização no acesso aos dados.
| Usuário          | Acesso                             |
|------------------|------------------------------------|
| `analyst_movies` | Apenas filmes                      |
| `analyst_tv`     | Apenas séries                      |
| `analyst_games`  | Apenas videogames                  |
| `analyst_docs`   | Apenas documentários               |
| `analyst_all`    | Leitura em todas as tabelas        |
| `data_scientist` | Leitura e escrita no `analytics`   |

---

## 5. Views
As views criadas neste projeto oferecem resumos dos dados tratados, facilitando análises rápidas e focadas em insights de negócio.
- `production_summary`
- `top_actors_by_type`
- `yearly_production_trends`
- `crew_analysis`

### 🧠 Perguntas de Negócio
As views organizam as informações para consultas eficientes, ajudando a responder perguntas estratégicas, como:
1. Tipo mais frequente?
2. Top 10 atores ativos?
3. Evolução de 50 anos?
4. Maiores picos de produção?
5. % com papéis específicos?
