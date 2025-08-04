#!/bin/bash

echo "Starting PostgreSQL HA Cluster..."
echo

# Make the auto setup script executable
chmod +x scripts/auto_setup.sh

# Run the auto setup
./scripts/auto_setup.sh

echo
echo "PostgreSQL HA Cluster is ready!"
echo
echo "Quick access:"
echo "  • HAProxy Stats: http://localhost:8404 (admin/admin123)"
echo "  • PgAdmin: http://localhost:8080 (admin@admin.com/admin123)"
echo "  • PostgreSQL: localhost:5432 (primary), localhost:5433 (standby)"
echo "  • HAProxy Load Balancer: localhost:5000"
echo
echo "Test failover:"
echo "  docker compose stop postgresql-primary"
echo "  docker compose start postgresql-primary" 