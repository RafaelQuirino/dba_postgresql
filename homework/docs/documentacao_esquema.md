
# Documentação do Esquema do Banco de Dados

## Análise do Projeto e Decisões de Modelagem

O projeto foi estruturado para atender a requisitos de ingestão massiva de dados, consultas analíticas e controle de acesso granular. As principais decisões e etapas foram:

- **Separação de esquemas:**
	- `raw_data`: armazena os dados brutos, refletindo a estrutura original dos arquivos fornecidos.
	- `analytics`: armazena tabelas especializadas e particionadas para consultas analíticas otimizadas.

- **Modelagem relacional clássica:**
	- Relações normalizadas: `producao`, `pessoa`, `equipe`.
	- Chaves primárias e estrangeiras garantem integridade referencial.

- **Tabelas analíticas especializadas:**
	- Cada tipo de produção (filme, série, etc.) possui uma tabela dedicada em `analytics`, facilitando queries segmentadas e aplicação de índices específicos.

- **Particionamento:**
	- Tabela `analytics.pessoa` particionada por primeira letra do nome, com trigger para garantir consistência.
	- Tabela `analytics.equipe` particionada por hash de `producao_id` em 42 partições, otimizando joins e distribuição de dados.

- **Índices:**
	- Criados em colunas de busca e junção (`producao_id`, `pessoa_id`, `primeira_letra`, `papel`).
	- Índices compostos e específicos para acelerar queries analíticas e relatórios.

- **Controle de acesso:**
	- Usuários especializados com permissões restritas por tipo de produção e acesso total para cientistas de dados.
	- Scripts de GRANT/REVOKE e matriz de permissões documentados.

- **Views analíticas:**
	- Views para sumarização, tendências, top atores e análise de equipe, facilitando relatórios e BI.

- **Automação e documentação:**
	- Scripts SQL organizados por etapa.
	- Documentação detalhada para cada fase do projeto.

## DER (Diagrama Entidade-Relacionamento)

![DER](docs/der.png) <!-- Substitua este caminho pelo caminho correto da imagem exportada do DER -->

O DER está disponível no arquivo `docs/der.puml` (PlantUML).

## Definições de Tabelas e Restrições

- Tabelas principais: `raw_data.producao`, `raw_data.pessoa`, `raw_data.equipe`
- Tabelas analíticas: `analytics.movies`, `analytics.tv_shows`, ...
- Tabelas particionadas: `analytics.pessoa`, `analytics.equipe`

Consulte os arquivos SQL para detalhes de colunas, tipos e constraints.

## Estratégias de Indexação

- Índices em colunas de busca e junção (ex: `producao_id`, `pessoa_id`, `primeira_letra`)
- Índices específicos para analytics e performance

---

Arquivo DER em PlantUML: `docs/der.puml`
