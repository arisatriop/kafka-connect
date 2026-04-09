# Kafka Connect — Confluent Image Setup

CDC pipeline using Confluent Platform components. Captures change events from PostgreSQL via Debezium and syncs them to a target database via JDBC Sink.

---

## Architecture

```
PostgreSQL (Source)
      │
      ▼
Debezium Source Connector  ──►  Kafka (KRaft)  ──►  JDBC Sink Connector
                                                           │
                                                           ▼
                                                  PostgreSQL (Target)
```

---

## Services

| Service | Image | Description |
|---------|-------|-------------|
| `postgres` | `postgres:15` | PostgreSQL with logical replication enabled |
| `kafka` | `confluentinc/cp-kafka:7.4.0` | Kafka broker in KRaft mode (no Zookeeper) |
| `kafka-init` | `confluentinc/cp-kafka:7.4.0` | Init container to fix Kafka volume permissions |
| `connect` | `confluentinc/cp-kafka-connect:7.4.0` | Kafka Connect with Debezium + JDBC connectors |
| `kafbat-ui` | `kafbat/kafka-ui:v1.4.2` | Kafka management UI |

### Installed Connectors (auto-installed on startup)

| Connector | Version |
|-----------|---------|
| `debezium/debezium-connector-postgresql` | `2.5.4` |
| `confluentinc/kafka-connect-jdbc` | `10.7.4` |

---

## Compose Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Local development — ports bound to `127.0.0.1` |
| `docker-compose.prod-grade.yml` | Production — stricter resource settings, no localhost binding |

---

## Ports

### Development (`docker-compose.yml`)

| Service | Host | Container |
|---------|------|-----------|
| PostgreSQL | `127.0.0.1:5432` | `5432` |
| Kafka Connect REST API | — | `8083` (internal only) |
| Kafbat UI | `127.0.0.1:8080` | `8080` |

### Production (`docker-compose.prod-grade.yml`)

| Service | Host | Container |
|---------|------|-----------|
| PostgreSQL | `5433` | `5432` |
| Kafka Connect REST API | — | `8083` (internal only) |
| Kafbat UI | `8080` | `8080` |

> Kafka Connect REST API is only accessible within the Docker network. Use `docker exec` or route through the UI.

---

## Quick Start

### 1. Start Services

```bash
# Development
docker-compose up -d

# Production
docker-compose -f docker-compose.prod-grade.yml up -d
```

> On first start, Kafka Connect will install the connectors before starting. This takes ~1–2 minutes.

### 2. Verify Connect is Ready

```bash
# Wait until this returns HTTP 200
curl http://localhost:8083/

# Or check via docker logs
docker logs connect -f
```

### 3. Deploy Connectors

Configure and register the connectors via the Kafka Connect REST API:

```bash
# Register source connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/source-postgres-connector.json.sh

# Register sink connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/sink-jdbc-connector.json.sh
```

### 4. Monitor

- **Kafbat UI**: http://localhost:8080 (login: `admin` / `admin123`)

---

## Connector Configuration

See the dedicated documentation files:

- [`connectors/source-connector.md`](connectors/source-connector.md) — Debezium PostgreSQL Source
- [`connectors/sink-connector.md`](connectors/sink-connector.md) — Confluent JDBC Sink

Config templates:

- [`connectors/source-postgres-connector.json.sh`](connectors/source-postgres-connector.json.sh)
- [`connectors/sink-jdbc-connector.json.sh`](connectors/sink-jdbc-connector.json.sh)

---

## Managing Connectors

All connector management is done through the **Kafka Connect REST API** (port `8083`).

### Check Status

```bash
# List all connectors
curl http://localhost:8083/connectors

# Get connector status
curl http://localhost:8083/connectors/{connector-name}/status

# Get connector config
curl http://localhost:8083/connectors/{connector-name}/config
```

### Restart / Delete

```bash
# Restart a connector
curl -X POST http://localhost:8083/connectors/{connector-name}/restart

# Delete a connector
curl -X DELETE http://localhost:8083/connectors/{connector-name}

# List available plugins
curl http://localhost:8083/connector-plugins
```

---

## CRUD Support

This setup supports full CDC operations:

| Operation | Type | How |
|-----------|------|-----|
| `INSERT` | Hard | Captured as `c` event by Debezium |
| `UPDATE` | Hard | Captured as `u` event by Debezium |
| Soft DELETE | Soft | `UPDATE` setting `deleted_at` / `deleted_by` |
| Hard DELETE | Hard | Captured as `d` event + tombstone → deleted from sink |

> Hard DELETE requires `tombstones.on.delete: true` on the source connector and `delete.enabled: true` on the sink connector.

---

## Troubleshooting

### Kafka Connect not starting

```bash
docker logs connect -f
```

Common causes: Kafka not ready yet, or connector install failed. Wait and retry.

### Connector stuck in FAILED state

```bash
# Check error details
curl http://localhost:8083/connectors/{connector-name}/status

# Restart the connector
curl -X POST http://localhost:8083/connectors/{connector-name}/restart
```

### Inspect Kafka Topics

Via Kafbat UI at http://localhost:8080, or via CLI:

```bash
# List topics
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list

# Consume messages from a topic
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic {topic_name} \
  --from-beginning
```

### PostgreSQL Replication Slot

```bash
# Check active replication slots
docker exec postgres psql -U postgres -c "SELECT * FROM pg_replication_slots;"

# Drop a stale slot (if connector was deleted without cleanup)
docker exec postgres psql -U postgres -c "SELECT pg_drop_replication_slot('{slot_name}');"
```
