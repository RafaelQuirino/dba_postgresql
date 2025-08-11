
# Análise e Otimização de Performance

## Estratégias de Otimização de Consultas

- **Uso de índices:**
	- Índices simples e compostos em colunas de busca e junção (`producao_id`, `pessoa_id`, `primeira_letra`, `papel`).
	- Índices criados nas tabelas particionadas e analíticas para acelerar filtros e joins.

- **Particionamento:**
	- `analytics.pessoa` particionada por primeira letra do nome, reduzindo o escopo de buscas por nome.
	- `analytics.equipe` particionada por hash de `producao_id`, distribuindo grandes volumes de dados e facilitando paralelismo.

- **Views analíticas:**
	- Views pré-agrupadas e sumarizadas para evitar cálculos repetidos em queries de BI.

- **EXPLAIN ANALYZE:**
	- Utilizado para identificar gargalos, analisar planos de execução e validar o uso de índices e partições.

- **Materialized Views:**
	- Recomendada para relatórios pesados e consultas recorrentes, reduzindo o tempo de resposta.

- **Paralelismo:**
	- Configuração de workers paralelos para acelerar agregações e joins em tabelas grandes.

## Exemplos de Análise com EXPLAIN

```sql
EXPLAIN ANALYZE SELECT * FROM analytics.pessoa WHERE nome ILIKE 'A%';
```
*Verifica se o índice e a partição correta estão sendo usados.*

```sql
EXPLAIN ANALYZE SELECT pessoa_id, COUNT(*) FROM analytics.equipe GROUP BY pessoa_id;
```
*Avalia o uso de paralelismo e distribuição do hash.*

## Recomendações de Índices

- Índices simples: `producao_id`, `pessoa_id`, `primeira_letra`, `papel`
- Índices compostos: (`producao_id`, `pessoa_id`), (`pessoa_id`, `papel`)
- Índices para colunas de filtro em views e relatórios

## Benchmarks de Performance

- Testes realizados com e sem particionamento e índices
- Redução significativa do tempo de queries analíticas após criação de views e índices
- Exemplo: consulta de top atores caiu de minutos para segundos após materialização e indexação

## Decisões de Tuning

- Ajuste de `work_mem` e `maintenance_work_mem` para operações de agregação
- Aumento de `max_parallel_workers_per_gather` para permitir maior paralelismo
- Monitoramento de locks e deadlocks em operações concorrentes

## Boas Práticas

- Recriar índices periodicamente após grandes cargas
- Monitorar estatísticas com `pg_stat_statements`
- Automatizar análise de planos e alertas de queries lentas

---

Essas estratégias garantem consultas rápidas e escaláveis mesmo com grandes volumes de dados.
