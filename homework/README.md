# 📚 CineTech Studios - Guia do Projeto de DBA

## 1. Visão Geral
| Componentes Incluídos                                                                 |
|---------------------------------------------------------------------------------------|
| - Projeto do banco                                                                    |
| - Ingestão com Python                                                                 |
| - Gerenciamento de usuários                                                           |
| - Relatórios e visualizações via views                                                |

---

## 2. Estrutura do Schema `raw_data`
| Tabela     | Descrição                            |
|------------|--------------------------------------|
| `producao` | Dados de produção                    |
| `pessoa`   | Dados pessoais                       |
| `equipe`   | Relações entre produção e equipe     |

**Scripts Python**: Ingestão de `.txt`, mensagens de sucesso/erro.

---

## 3. Estrutura do Schema `analytics`

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

**Recursos:**
- Índices: `ano_producao`, `nome_pessoa`, `titulo`
- Particionamento: `movies` por década

---

## 4. Controle de Acesso

| Usuário         | Acesso                            |
|------------------|------------------------------------|
| `analyst_movies` | Apenas filmes                      |
| `analyst_tv`     | Apenas séries                      |
| `analyst_games`  | Apenas videogames                  |
| `analyst_docs`   | Apenas documentários               |
| `analyst_all`    | Leitura em todas as tabelas        |
| `data_scientist` | Leitura e escrita no `analytics`   |

---

## 5. Views Criadas

- `production_summary`
- `top_actors_by_type`
- `yearly_production_trends`
- `crew_analysis`

### 🧠 Perguntas Respondidas:
1. Tipo mais frequente?
2. Top 10 atores ativos?
3. Evolução de 50 anos?
4. Maiores picos de produção?
5. % com papéis específicos?
