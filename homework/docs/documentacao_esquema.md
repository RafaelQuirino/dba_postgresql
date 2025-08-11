# Documentação do Esquema do Banco de Dados

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
