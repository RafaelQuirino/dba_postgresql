
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

## Foi otimizada a consulta com o explain abaixo removendo a cláusula ORDER BY da subconsulta


#### Consulta antiga

```sql
SELECT
p.pessoa_id,
p.nome,
eq.total_producoes
FROM (
	SELECT pessoa_id, COUNT() AS total_producoes
	FROM analytics.equipe
	GROUP BY pessoa_id
	ORDER BY COUNT() DESC
	LIMIT 10
) eq
JOIN analytics.pessoa p ON p.pessoa_id = eq.pessoa_id
ORDER BY eq.total_producoes DESC
```

### Consulta nova
```sql
SELECT
  p.pessoa_id,
  p.nome,
  eq.total_producoes
FROM (
  SELECT pessoa_id, COUNT(*) AS total_producoes
  FROM analytics.equipe
  GROUP BY pessoa_id
  LIMIT 10
) eq
JOIN analytics.pessoa p ON p.pessoa_id = eq.pessoa_id
ORDER BY eq.total_producoes DESC;
```

### Explain 
```
Sort (cost=263175.67..263433.49 rows=103125 width=31)
Sort Key: eq.total_producoes DESC
-> Hash Join (cost=201180.81..252120.94 rows=103125 width=31)
Hash Cond: (p.pessoa_id = eq.pessoa_id)
-> Append (cost=0.00..45411.36 rows=2062491 width=23)
-> Seq Scan on pessoa_a p_1 (cost=0.00..1460.19 rows=85819 width=23)
-> Seq Scan on pessoa_b p_2 (cost=0.00..2951.73 rows=173573 width=23)
-> Seq Scan on pessoa_c p_3 (cost=0.00..2416.53 rows=141753 width=23)
-> Seq Scan on pessoa_d p_4 (cost=0.00..1897.69 rows=111269 width=23)
-> Seq Scan on pessoa_e p_5 (cost=0.00..634.98 rows=37398 width=23)
-> Seq Scan on pessoa_f p_6 (cost=0.00..1268.65 rows=74465 width=23)
-> Seq Scan on pessoa_g p_7 (cost=0.00..1860.64 rows=109064 width=23)
-> Seq Scan on pessoa_h p_8 (cost=0.00..1958.33 rows=115333 width=23)
-> Seq Scan on pessoa_i p_9 (cost=0.00..279.79 rows=16479 width=23)
-> Seq Scan on pessoa_j p_10 (cost=0.00..813.56 rows=47956 width=23)
-> Seq Scan on pessoa_k p_11 (cost=0.00..1735.42 rows=102242 width=23)
-> Seq Scan on pessoa_l p_12 (cost=0.00..1869.99 rows=110399 width=23)
-> Seq Scan on pessoa_m p_13 (cost=0.00..3220.71 rows=188871 width=23)
-> Seq Scan on pessoa_n p_14 (cost=0.00..795.54 rows=46854 width=23)
-> Seq Scan on pessoa_o p_15 (cost=0.00..587.98 rows=34598 width=23)
-> Seq Scan on pessoa_p p_16 (cost=0.00..1772.26 rows=104026 width=23)
-> Seq Scan on pessoa_q p_17 (cost=0.00..77.20 rows=4520 width=23)
-> Seq Scan on pessoa_r p_18 (cost=0.00..1796.38 rows=105838 width=23)
-> Seq Scan on pessoa_s p_19 (cost=0.00..3411.87 rows=200187 width=23)
-> Seq Scan on pessoa_t p_20 (cost=0.00..1290.51 rows=75851 width=23)
-> Seq Scan on pessoa_u p_21 (cost=0.00..128.89 rows=7589 width=23)
-> Seq Scan on pessoa_v p_22 (cost=0.00..850.06 rows=49506 width=24)
-> Seq Scan on pessoa_w p_23 (cost=0.00..1363.61 rows=80361 width=23)
-> Seq Scan on pessoa_x p_24 (cost=0.00..18.63 rows=1063 width=20)
-> Seq Scan on pessoa_y p_25 (cost=0.00..275.67 rows=16267 width=22)
-> Seq Scan on pessoa_z p_26 (cost=0.00..301.05 rows=17705 width=23)
-> Seq Scan on pessoa_others p_27 (cost=0.00..61.05 rows=3505 width=25)
-> Hash (cost=201180.69..201180.69 rows=10 width=16)
-> Subquery Scan on eq (cost=201180.56..201180.69 rows=10 width=16)
-> Limit (cost=201180.56..201180.59 rows=10 width=16)
-> Sort (cost=201180.56..201181.06 rows=200 width=16)
Sort Key: (count(*)) DESC
-> Finalize GroupAggregate (cost=201125.57..201176.24 rows=200 width=16)
Group Key: equipe.pessoa_id
-> Gather Merge (cost=201125.57..201172.24 rows=400 width=16)
Workers Planned: 2
-> Sort (cost=200125.55..200126.05 rows=200 width=16)
Sort Key: equipe.pessoa_id
-> Partial HashAggregate (cost=200115.90..200117.90 rows=200 width=16)
Group Key: equipe.pessoa_id
-> Parallel Append (cost=0.00..174809.76 rows=5061229 width=8)
-> Parallel Seq Scan on equipe_hash_16 equipe_17 (cost=0.00..3647.53 rows=174253 width=8)
-> Parallel Seq Scan on equipe_hash_13 equipe_14 (cost=0.00..3645.89 rows=174089 width=8)
-> Parallel Seq Scan on equipe_hash_31 equipe_32 (cost=0.00..3640.47 rows=173847 width=8)
-> Parallel Seq Scan on equipe_hash_39 equipe_40 (cost=0.00..3639.23 rows=173823 width=8)
-> Parallel Seq Scan on equipe_hash_22 equipe_23 (cost=0.00..3631.21 rows=173621 width=8)
-> Parallel Seq Scan on equipe_hash_33 equipe_34 (cost=0.00..3624.41 rows=173141 width=8)
-> Parallel Seq Scan on equipe_hash_26 equipe_27 (cost=0.00..3621.36 rows=172936 width=8)
-> Parallel Seq Scan on equipe_hash_2 equipe_3 (cost=0.00..3597.49 rows=171949 width=8)
-> Parallel Seq Scan on equipe_hash_6 equipe_7 (cost=0.00..3596.05 rows=171905 width=8)
-> Parallel Seq Scan on equipe_hash_5 equipe_6 (cost=0.00..3593.26 rows=171826 width=8)
-> Parallel Seq Scan on equipe_hash_35 equipe_36 (cost=0.00..3592.48 rows=171648 width=8)
-> Parallel Seq Scan on equipe_hash_36 equipe_37 (cost=0.00..3584.88 rows=171188 width=8)
-> Parallel Seq Scan on equipe_hash_3 equipe_4 (cost=0.00..3581.00 rows=171200 width=8)
-> Parallel Seq Scan on equipe_hash_21 equipe_22 (cost=0.00..3573.39 rows=170839 width=8)
-> Parallel Seq Scan on equipe_hash_34 equipe_35 (cost=0.00..3571.21 rows=170621 width=8)
-> Parallel Seq Scan on equipe_hash_17 equipe_18 (cost=0.00..3569.98 rows=170698 width=8)
-> Parallel Seq Scan on equipe_hash_20 equipe_21 (cost=0.00..3564.64 rows=170264 width=8)
-> Parallel Seq Scan on equipe_hash_8 equipe_9 (cost=0.00..3564.42 rows=170242 width=8)
-> Parallel Seq Scan on equipe_hash_27 equipe_28 (cost=0.00..3564.36 rows=170336 width=8)
-> Parallel Seq Scan on equipe_hash_10 equipe_11 (cost=0.00..3560.15 rows=170315 width=8)
-> Parallel Seq Scan on equipe_hash_12 equipe_13 (cost=0.00..3559.51 rows=170151 width=8)
-> Parallel Seq Scan on equipe_hash_15 equipe_16 (cost=0.00..3559.04 rows=170204 width=8)
-> Parallel Seq Scan on equipe_hash_25 equipe_26 (cost=0.00..3556.23 rows=169923 width=8)
-> Parallel Seq Scan on equipe_hash_1 equipe_2 (cost=0.00..3554.19 rows=169819 width=8)
-> Parallel Seq Scan on equipe_hash_9 equipe_10 (cost=0.00..3551.41 rows=169741 width=8)
-> Parallel Seq Scan on equipe_hash_11 equipe_12 (cost=0.00..3549.88 rows=169688 width=8)
-> Parallel Seq Scan on equipe_hash_18 equipe_19 (cost=0.00..3546.25 rows=169425 width=8)
-> Parallel Seq Scan on equipe_hash_30 equipe_31 (cost=0.00..3542.70 rows=169370 width=8)
-> Parallel Seq Scan on equipe_hash_7 equipe_8 (cost=0.00..3541.39 rows=169239 width=8)
-> Parallel Seq Scan on equipe_hash_28 equipe_29 (cost=0.00..3539.25 rows=169225 width=8)
-> Parallel Seq Scan on equipe_hash_4 equipe_5 (cost=0.00..3537.96 rows=169296 width=8)
-> Parallel Seq Scan on equipe_hash_41 equipe_42 (cost=0.00..3535.29 rows=169029 width=8)
-> Parallel Seq Scan on equipe_hash_14 equipe_15 (cost=0.00..3517.89 rows=168189 width=8)
-> Parallel Seq Scan on equipe_hash_23 equipe_24 (cost=0.00..3512.01 rows=167701 width=8)
-> Parallel Seq Scan on equipe_hash_19 equipe_20 (cost=0.00..3508.73 rows=167773 width=8)
-> Parallel Seq Scan on equipe_hash_40 equipe_41 (cost=0.00..3508.13 rows=167613 width=8)
-> Parallel Seq Scan on equipe_hash_38 equipe_39 (cost=0.00..3505.44 rows=167544 width=8)
-> Parallel Seq Scan on equipe_hash_29 equipe_30 (cost=0.00..3499.45 rows=167145 width=8)
-> Parallel Seq Scan on equipe_hash_32 equipe_33 (cost=0.00..3496.45 rows=167145 width=8)
-> Parallel Seq Scan on equipe_hash_37 equipe_38 (cost=0.00..3493.74 rows=167074 width=8)
-> Parallel Seq Scan on equipe_hash_0 equipe_1 (cost=0.00..3471.36 rows=165936 width=8)
-> Parallel Seq Scan on equipe_hash_24 equipe_25 (cost=0.00..3453.92 rows=165292 width=8)
JIT:
Functions: 152
Options: Inlining false, Optimization false, Expressions true, Deforming true
```


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
