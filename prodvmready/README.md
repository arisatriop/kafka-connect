# Kafka Connect Production Setup

This directory contains a production-ready Kafka Connect setup with all necessary components for running on a VM with Docker.

## 🏗️ Architecture

The setup includes the following components:

1. **PostgreSQL** - Database server (manual configuration)
2. **Confluent Kafka Broker (KRaft mode)** - Single-node Kafka cluster
3. **Schema Registry** - For Avro schema management
4. **Kafka Connect** - With JDBC and Debezium plugins pre-installed
5. **Landoop Connect UI** - Web interface for managing connectors
6. **AKHQ** - Advanced Kafka management UI
7. **Kafdrop** - Alternative Kafka topic browser

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+ (or docker-compose 1.29+)
- At least 4GB RAM available for Docker
- Ports 5432, 8000, 8080, 8081, 8083, 9000, 9092, 9101 available

### Starting the Stack

```bash
# Make the management script executable
chmod +x manage.sh

# Start all services
./manage.sh start
```

Or manually with docker-compose:

```bash
docker compose up -d
```

### Accessing Services

Once all services are running, you can access:

| Service | URL | Description |
|---------|-----|-------------|
| Kafka Broker | `localhost:9092` | Kafka bootstrap servers |
| PostgreSQL | `localhost:5432` | Database (postgres/postgres123) |
| Schema Registry | http://localhost:8081 | Schema management API |
| Kafka Connect | http://localhost:8083 | Connect REST API |
| Connect UI | http://localhost:8000 | Connector management interface |
| AKHQ | http://localhost:8080 | Advanced Kafka UI |
| Kafdrop | http://localhost:9000 | Kafka topic browser |

## 📋 Management Commands

Use the included `manage.sh` script for easy management:

```bash
# Start the entire stack
./manage.sh start

# Stop the entire stack
./manage.sh stop

# Restart the entire stack
./manage.sh restart

# Check health of all services
./manage.sh health

# Create a sample Debezium connector
./manage.sh create-connector

# List all active connectors
./manage.sh list-connectors

# View logs of a specific service
./manage.sh logs kafka-connect

# Clean up everything (including volumes)
./manage.sh cleanup

# Show help
./manage.sh help
```

## 🔌 Creating Connectors

Connectors are created manually via the REST API or web interfaces after setting up your database and schemas.

### Via REST API

Create connectors by POSTing JSON configuration to the Connect REST API:

```bash
# Example: Create a Debezium PostgreSQL source connector
curl -X POST \
     -H "Content-Type: application/json" \
     --data '{
       "name": "my-postgres-source",
       "config": {
         "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
         "database.hostname": "postgres",
         "database.port": "5432",
         "database.user": "your_user",
         "database.password": "your_password",
         "database.dbname": "your_database",
         "database.server.name": "your_server",
         "table.include.list": "public.your_table"
       }
     }' \
     http://localhost:8083/connectors

# Check connector status
curl http://localhost:8083/connectors/my-postgres-source/status
```

### Via Web Interfaces

Use the visual interfaces for easier connector management:
- **Connect UI**: http://localhost:8000 - Visual connector creation and management
- **AKHQ**: http://localhost:8080 - Advanced management with schema support

### Available Connector Plugins

Your setup includes these pre-installed plugins:
- **Debezium PostgreSQL Connector** - For Change Data Capture
- **JDBC Source Connector** - For polling database tables  
- **JDBC Sink Connector** - For writing to database tables

Check available plugins:
```bash
curl http://localhost:8083/connector-plugins
```

## 🗄️ Database Setup

The PostgreSQL database is available but **requires manual setup** for your specific use case.

### Connection Details
- **Host**: localhost:5432
- **Default User**: postgres
- **Default Password**: postgres123
- **Default Database**: postgres

### Manual Configuration Steps

1. **Connect to PostgreSQL**:
```bash
# Via Docker
docker exec -it postgres-db psql -U postgres

# Or via external client
psql -h localhost -p 5432 -U postgres
```

2. **Create your databases**:
```sql
CREATE DATABASE your_source_db;
CREATE DATABASE your_target_db;
```

3. **For Debezium CDC (if needed)**:
```sql
-- Enable logical replication
ALTER SYSTEM SET wal_level = logical;
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET max_replication_slots = 10;

-- Restart PostgreSQL container
-- docker restart postgres-db

-- Create replication user
CREATE USER replicator WITH REPLICATION PASSWORD 'your_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;

-- Create publication for tables you want to replicate
CREATE PUBLICATION your_publication FOR ALL TABLES;
-- OR for specific tables:
-- CREATE PUBLICATION your_publication FOR TABLE table1, table2;
```

4. **Create your tables and data** according to your requirements.

## 📊 Monitoring & Management

### AKHQ Features
- Topic browsing and management
- Consumer group monitoring  
- Schema registry management
- Connector management
- Kafka cluster overview

### Connect UI Features
- Visual connector creation
- Connector status monitoring
- Task management
- Configuration editing

### Health Checks

All services include health checks. Monitor with:

```bash
# Check all service health
./manage.sh health

# View specific service logs
./manage.sh logs <service-name>

# Check Docker container status
docker compose ps
```

## ⚙️ Production Configuration

### Resource Limits

For production use, consider adding resource limits:

```yaml
services:
  kafka:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
```

### Security Enhancements

1. **Change default passwords** in docker-compose.yml
2. **Enable SSL/TLS** for Kafka and Connect
3. **Configure authentication** for UI components
4. **Use secrets management** for credentials
5. **Enable firewall rules** for exposed ports

### Volume Configuration

Persistent volumes are configured for:
- `postgres_data` - PostgreSQL data
- `kafka_data` - Kafka logs and metadata

For production, consider using named volumes or bind mounts:

```yaml
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/kafka-connect/postgres
```

## 🛠️ Troubleshooting

### Common Issues

**Services not starting:**
```bash
# Check logs
./manage.sh logs <service-name>

# Verify ports are not in use
netstat -tlnp | grep -E "(8080|8083|9092)"
```

**Connector creation fails:**
```bash
# Check Connect service is ready
curl http://localhost:8083/connectors

# Verify connector plugins
curl http://localhost:8083/connector-plugins
```

**Database connection issues:**
```bash
# Test PostgreSQL connection
docker exec postgres-db psql -U postgres -d sourcedb -c "\dt"

# Check database logs
./manage.sh logs postgres
```

### Log Locations

- **Kafka Connect**: `./manage.sh logs kafka-connect`
- **Kafka Broker**: `./manage.sh logs kafka`  
- **PostgreSQL**: `./manage.sh logs postgres`

### Reset Everything

To start fresh:

```bash
# Stop and remove everything
./manage.sh cleanup

# Start again
./manage.sh start
```

## 📈 Scaling for Production

### Multi-Node Setup

For production workloads:

1. **Multiple Kafka Brokers**: Update `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR` to 3
2. **Multiple Connect Workers**: Scale connect service replicas
3. **External PostgreSQL**: Use managed database service
4. **Load Balancer**: Add nginx/haproxy for Connect REST API

### Performance Tuning

Key settings to adjust:

```yaml
# Kafka Connect
CONNECT_OFFSET_FLUSH_INTERVAL_MS: 10000
CONNECT_CONSUMER_MAX_POLL_RECORDS: 500

# Kafka Broker  
KAFKA_NUM_NETWORK_THREADS: 8
KAFKA_NUM_IO_THREADS: 16
KAFKA_SOCKET_SEND_BUFFER_BYTES: 102400
KAFKA_SOCKET_RECEIVE_BUFFER_BYTES: 102400
```

## 🤝 Contributing

To contribute improvements:

1. Test changes thoroughly
2. Update documentation
3. Validate all services start correctly
4. Check connector functionality

## 📝 License

This setup is provided as-is for educational and development purposes.

---

**Production Checklist:**
- [ ] Change all default passwords
- [ ] Configure SSL/TLS encryption  
- [ ] Set up proper monitoring
- [ ] Configure backup strategies
- [ ] Implement security policies
- [ ] Test disaster recovery
- [ ] Set up log aggregation
- [ ] Configure alerting