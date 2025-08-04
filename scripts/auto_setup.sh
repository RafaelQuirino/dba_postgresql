#!/bin/bash

set -e

echo "=== PostgreSQL HA Auto Setup ==="
echo

# Step 1: Clean up any existing setup
echo "1. Cleaning up existing setup..."
docker compose down -v 2>/dev/null || true
docker volume prune -f 2>/dev/null || true

# Step 2: Start all services
echo "2. Starting all services..."
docker compose up -d

# Step 3: Wait for primary to be ready
echo "3. Waiting for primary to be ready..."
sleep 20

# Step 4: Create test database and table
echo "4. Creating test database and table..."
docker exec postgresql-primary su postgres -c "psql -c \"CREATE DATABASE testdb;\" 2>/dev/null || echo 'Database testdb already exists'"
docker exec postgresql-primary su postgres -c "psql -d testdb -c \"CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, name VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);\""

# Step 5: Register primary with repmgr
echo "5. Registering primary with repmgr..."
docker exec postgresql-primary su postgres -c "repmgr primary register --force"

# Step 6: Wait for standby to initialize
echo "6. Waiting for standby to initialize..."
sleep 15

# Step 7: Stop standby for backup
echo "7. Stopping standby for backup..."
docker compose stop postgresql-standby

# Step 8: Create base backup
echo "8. Creating base backup..."
docker exec postgresql-primary su postgres -c "rm -rf /tmp/standby_backup"
docker exec postgresql-primary su postgres -c "pg_basebackup -h localhost -U repmgr -D /tmp/standby_backup -v -P -W"

# Step 9: Copy backup to standby
echo "9. Copying backup to standby..."
docker cp postgresql-primary:/tmp/standby_backup ./standby_backup_temp
docker cp ./standby_backup_temp/. postgresql-standby:/var/lib/postgresql/data/
rm -rf ./standby_backup_temp

# Step 10: Configure standby for replication
echo "10. Configuring standby for replication..."
docker exec postgresql-standby su postgres -c "touch /var/lib/postgresql/data/standby.signal"
docker exec postgresql-standby su postgres -c "echo \"primary_conninfo = 'host=postgresql-primary port=5432 user=repmgr password=repmgr123 application_name=postgresql-standby'\" >> /var/lib/postgresql/data/postgresql.conf"

# Step 11: Start standby
echo "11. Starting standby..."
docker compose start postgresql-standby

# Step 12: Wait for standby to be ready
echo "12. Waiting for standby to be ready..."
sleep 15

# Step 13: Copy pg_hba.conf to primary data directory
echo "13. Configuring primary authentication..."
docker cp conf/pg_hba.conf postgresql-primary:/var/lib/postgresql/data/pg_hba.conf
docker exec postgresql-primary su postgres -c "pg_ctl reload"

# Step 14: Register standby with repmgr
echo "14. Registering standby with repmgr..."
docker exec postgresql-primary su postgres -c "psql -d repmgr -c \"INSERT INTO repmgr.nodes (node_id, node_name, type, location, priority, conninfo, repluser, config_file, upstream_node_id, slot_name) VALUES (2, 'postgresql-standby', 'standby', 'default', 50, 'host=postgresql-standby user=repmgr password=repmgr123 dbname=repmgr', 'repmgr', '/etc/repmgr.conf', 1, 'repmgr_2_postgresql_standby') ON CONFLICT (node_id) DO NOTHING;\""

# Step 15: Test replication
echo "15. Testing replication..."
docker exec postgresql-primary su postgres -c "psql -d testdb -c \"INSERT INTO test_table (name) VALUES ('Auto Setup Test - $(date)');\""
sleep 5
docker exec postgresql-standby su postgres -c "psql -d testdb -c \"SELECT COUNT(*) as total_records FROM test_table;\""

# Step 16: Enable synchronous replication (optional)
echo "16. Enabling synchronous replication..."
docker exec postgresql-primary su postgres -c "psql -c \"ALTER SYSTEM SET synchronous_commit = on;\""
docker exec postgresql-primary su postgres -c "psql -c \"ALTER SYSTEM SET synchronous_standby_names = 'postgresql-standby';\""
docker exec postgresql-primary su postgres -c "pg_ctl reload"

# Step 17: Show final status
echo "17. Final status check..."
echo
echo "=== Container Status ==="
docker compose ps
echo
echo "=== Cluster Status ==="
docker exec postgresql-primary su postgres -c "repmgr cluster show"
echo
echo "=== HAProxy Status ==="
curl -s -u admin:admin123 http://localhost:8404/stats | grep -A 5 -B 5 "postgresql-primary\|postgresql-standby" || echo "HAProxy stats not available yet"
echo
echo "=== Access Points ==="
echo "PostgreSQL Primary: localhost:5432"
echo "PostgreSQL Standby: localhost:5433"
echo "HAProxy Load Balancer: localhost:5000"
echo "HAProxy Stats: http://localhost:8404 (admin/admin123)"
echo "PgAdmin: http://localhost:8080 (admin@admin.com/admin123)"
echo
echo "=== Test Commands ==="
echo "Test primary: docker exec postgresql-primary su postgres -c \"psql -d testdb -c 'SELECT * FROM test_table;'\""
echo "Test standby: docker exec postgresql-standby su postgres -c \"psql -d testdb -c 'SELECT * FROM test_table;'\""
echo "Test HAProxy: docker exec postgresql-primary su postgres -c \"psql -h haproxy -p 5000 -U postgres -d testdb -c 'SELECT current_database();'\""
echo
echo "=== Setup Complete! ==="
echo "- All services are running"
echo "- Replication is configured"
echo "- HAProxy is load balancing"
echo "- PgAdmin is accessible"
echo "- Synchronous replication is enabled" 