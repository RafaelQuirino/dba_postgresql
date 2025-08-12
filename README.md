# dba_postgresql
Postgresql docker compose project with sample database, for a DBA course.


### Passo a passo para executar script de ingestaoa
1 Subir containers

```bash
docker compose up -d
```

### 2 Executar script de ingestao

1. Entrar no container python
```bash
docker compose run pubs-txt bash
```

2. Executar script

```bash
cd /homework/python
python ingestao_dados.py
```

