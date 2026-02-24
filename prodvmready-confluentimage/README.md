# Kafka Connect Setup dengan Confluent Images

## Services
- **PostgreSQL 15** - Source database dengan logical replication
- **Kafka (KRaft)** - Confluent Kafka tanpa Zookeeper  
- **Confluent Kafka Connect** - Kafka Connect dengan Confluent image + Debezium + JDBC connectors
- **Provectus Kafka UI** (connect-ui-1) - Modern Kafka management interface
- **Landoop Connect UI** (connect-ui-2) - Specialized connector management UI

## Ports
- PostgreSQL: `5433:5432`
- Kafka: `9092:9092`
- Kafka Connect: `8083:8083`
- Provectus UI (connect-ui-1): `8090:8080`
- Landoop UI (connect-ui-2): `8000:8000`

## Key Features
- **Confluent Platform components** untuk production-grade CDC
- **JSON serialization** dengan schema enabled untuk compatibility
- **Reliable field filtering** dengan Confluent JDBC Sink
- **Production-ready** dengan health checks dan proper networking
- **Complete CRUD support** - INSERT, UPDATE, soft DELETE, hard DELETE

## Advantages over Debezium-only Setup
- ✅ **Better field filtering** - Confluent JDBC Sink handles column selection properly
- ✅ **Production support** - Enterprise-grade connectors
- ✅ **JSON serialization** - Human-readable format
- ✅ **Reliable CDC operations** - More stable DELETE/UPDATE dengan field selection
- ✅ **Simpler setup** - No Schema Registry required

## Usage

### 1. Start Services
```bash
docker-compose up -d
```

### 2. Wait for All Services
```bash
# Check Connect status
./manage-confluent.sh check

# Check available connector plugins
./manage-confluent.sh plugins
```

### 3. Create Test Setup
```bash
# Create test tables and data
./manage-confluent.sh create-setup
./manage-confluent.sh insert-data
```

### 4. Deploy Connectors
```bash
# Deploy source connector
./manage-confluent.sh deploy-source

# Deploy sink connector
./manage-confluent.sh deploy-sink
```

### 5. Test CDC Operations
```bash
# Test all CRUD operations
./manage-confluent.sh test-ops

# Check connector status
./manage-confluent.sh status confluent-postgres-source
./manage-confluent.sh status confluent-postgres-sink
```

### 6. Monitor
- **Provectus Kafka UI** (connect-ui-1): http://localhost:8090
- **Landoop Connect UI** (connect-ui-2): http://localhost:8000

## Configuration Details

### Source Connector
- **Debezium PostgreSQL** connector dengan JSON serialization
- **Tombstones enabled** untuk hard delete support
- **Built-in schema management** tanpa external registry

### Sink Connector  
- **Confluent JDBC** connector (lebih reliable dari Debezium JDBC)
- **Field filtering** dengan `ReplaceField` transform
- **UPSERT mode** untuk INSERT/UPDATE operations
- **DELETE enabled** untuk hard delete operations
- **Auto schema evolution** untuk column changes

### Table Structure Support
**Source Table** (15 columns):
```sql
id, sub_package_id, source_id, vehicle_submodel_id, manufacture_id, 
vehicle_age_from, vehicle_age_to, term, flat_rate_per_term, 
created_at, created_by, updated_at, updated_by, deleted_at, deleted_by
```

**Target Table** (10 columns):
```sql
id, vehicle_age_from, vehicle_age_to, term, flat_rate_per_term,
created_at, created_by, updated_at, updated_by, deleted_at, deleted_by
```

**Field Filtering** automatically excludes:
- `sub_package_id` 
- `source_id`
- `vehicle_submodel_id`
- `manufacture_id`

## CRUD Operations

### ✅ INSERT
```sql  
INSERT INTO rates (sub_package_id, source_id, vehicle_submodel_id, manufacture_id, 
                  vehicle_age_from, vehicle_age_to, term, flat_rate_per_term, created_by)
VALUES (1, 2, 3, 4, 1, 5, 12, 100.00, 'user');
```

### ✅ UPDATE
```sql
UPDATE rates SET flat_rate_per_term = 150.00, updated_by = 'admin' WHERE id = 1;
```

### ✅ SOFT DELETE
```sql
UPDATE rates SET deleted_at = NOW(), deleted_by = 'admin' WHERE id = 1;
```

### ✅ HARD DELETE  
```sql
DELETE FROM rates WHERE id = 1;
```

## Troubleshooting

### Check Connector Status
```bash
./manage-confluent.sh status [connector-name]
./manage-confluent.sh config [connector-name]
```

### Check Topics and Messages
Via Provectus UI (http://localhost:8090) atau:
```bash
# List topics
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list

# Consume messages
docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic confluent-cdc.public.rates --from-beginning
```

### Check Schema Registry
```bash
# Schema Registry not available in this setup
# All schemas managed internally by Kafka Connect
```

### Common Issues

#### JSON Serialization Issues
Jika ada masalah dengan JSON, check connector configuration:
```bash
./manage-confluent.sh config [connector-name]
```

#### Permission Issues
```bash
# Restart PostgreSQL if needed
docker-compose restart postgres
```

#### Schema Evolution
Confluent setup automatically handles schema changes dengan:
```yaml
"auto.evolve": "true"
```
No external Schema Registry required.

## Management Commands
```bash
./manage-confluent.sh help                    # Show all commands
./manage-confluent.sh check                   # Check Connect health
./manage-confluent.sh list                    # List all connectors
./manage-confluent.sh plugins                 # List available plugins
./manage-confluent.sh create-setup            # Create test environment
./manage-confluent.sh insert-data             # Add test data
./manage-confluent.sh test-ops               # Test CRUD operations
./manage-confluent.sh deploy-source          # Deploy source connector
./manage-confluent.sh deploy-sink            # Deploy sink connector
./manage-confluent.sh status [name]          # Get connector status
./manage-confluent.sh delete [name]          # Delete connector
./manage-confluent.sh restart [name]         # Restart connector
```

Selamat mencoba setup Confluent yang lebih reliable! 🚀