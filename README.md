# Cluster PostgreSQL de Alta Disponibilidade

## Execução

### Setup Automático (Recomendado)
```bash
# Clone o repositório
git clone <url-do-repositorio>
cd dba_postgresql

# Execute com um comando
./start_ha.sh
```

### Setup Manual
```bash
# 1. Inicie todos os serviços
docker compose up -d

# 2. Execute o script de configuração automática
chmod +x scripts/auto_setup.sh
./scripts/auto_setup.sh
```

## Pontos de Acesso

| Serviço | URL/Porta | Credenciais |
|---------|-----------|-------------|
| **PgAdmin** | http://localhost:8080 | admin@admin.com / admin123 |
| **HAProxy Stats** | http://localhost:8404 | admin / admin123 |
| **PostgreSQL Primário** | localhost:5432 | postgres / postgres123 |
| **PostgreSQL Standby** | localhost:5433 | postgres / postgres123 |
| **HAProxy Load Balancer** | localhost:5000 | postgres / postgres123 |

## Testes Básicos

### 1. Teste de Replicação
```bash
# Inserir dados no primário
docker exec postgresql-primary su postgres -c "psql -d testdb -c \"INSERT INTO test_table (name) VALUES ('Teste de Replicação');\""

# Verificar se aparecem no standby
docker exec postgresql-standby su postgres -c "psql -d testdb -c \"SELECT * FROM test_table ORDER BY id DESC LIMIT 5;\""
```

### 2. Teste de Load Balancing
```bash
# Conectar via HAProxy
docker exec postgresql-primary su postgres -c "psql -h haproxy -p 5000 -U postgres -d testdb -c \"SELECT current_database();\""
```

### 3. Teste de Failover
```bash
# Parar primário
docker compose stop postgresql-primary

# Verificar se standby continua funcionando
docker exec postgresql-standby su postgres -c "psql -d testdb -c \"SELECT COUNT(*) FROM test_table;\""

# Restaurar primário
docker compose start postgresql-primary
```

## Verificação de Status

### Status dos Containers
```bash
docker compose ps
```

### Status do Cluster
```bash
docker exec postgresql-primary su postgres -c "repmgr cluster show"
```

### Status de Replicação
```bash
docker exec postgresql-primary su postgres -c "psql -c \"SELECT * FROM pg_stat_replication;\""
```

## Comandos Úteis

### Reiniciar Serviços
```bash
# Reiniciar primário
docker compose restart postgresql-primary

# Reiniciar standby
docker compose restart postgresql-standby

# Reiniciar tudo
docker compose restart
```

### Logs
```bash
# Logs do primário
docker compose logs postgresql-primary

# Logs do standby
docker compose logs postgresql-standby

# Logs em tempo real
docker compose logs -f postgresql-primary
```

### Parar Sistema
```bash
# Parar tudo
docker compose down

# Parar e remover volumes
docker compose down -v
```