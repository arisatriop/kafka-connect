# Source Connector — Debezium PostgreSQL

Captures change events (CDC) from a PostgreSQL database and publishes them to Kafka topics using the Debezium connector.

---

## Full Config

```json
{
  "name": "db_name.table_name.unique_suffix.source",
  "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
  "tasks.max": "1",

  "database.hostname": "postgres",
  "database.port": "5432",
  "database.user": "postgres",
  "database.password": "postgres",
  "database.dbname": "postgres",

  "topic.prefix": "db_name",
  "schema.include.list": "schema_name",
  "table.include.list": "schema_name.table_name",

  "plugin.name": "pgoutput",
  "slot.name": "slot_table_name.unique_suffix",
  "publication.autocreate.mode": "filtered",
  "snapshot.mode": "initial",

  "tombstones.on.delete": "true",
  "time.precision.mode": "connect",

  "heartbeat.interval.ms": "30000",
  "max.batch.size": "2048",
  "max.queue.size": "8192",
  "decimal.handling.mode": "double",
  "include.schema.changes": "false"
}
```

---

## Minimum Config

```json
{
  "name": "db_name.table_name.unique_suffix.source",
  "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
  "tasks.max": "1",

  "database.hostname": "postgres",
  "database.port": "5432",
  "database.user": "postgres",
  "database.password": "postgres",
  "database.dbname": "postgres",

  "topic.prefix": "db_name",
  "schema.include.list": "schema_name",
  "table.include.list": "schema_name.table_name",

  "plugin.name": "pgoutput",
  "slot.name": "slot_table_name.unique_suffix",

  "tombstones.on.delete": "true",
  "time.precision.mode": "connect"
}
```

---

## Configuration Reference

### Identity

| Key | Description |
|-----|-------------|
| `name` | Unique connector name. Convention: `db_name.table_name.unique_suffix.source` |
| `connector.class` | Always `io.debezium.connector.postgresql.PostgresConnector` |
| `tasks.max` | Number of parallel tasks. Typically `1` for CDC connectors |

### Database Connection

| Key | Description |
|-----|-------------|
| `database.hostname` | PostgreSQL host |
| `database.port` | PostgreSQL port (default: `5432`) |
| `database.user` | DB user with replication privileges |
| `database.password` | DB password |
| `database.dbname` | Target database name |

### Topic & Schema Filtering

| Key | Description |
|-----|-------------|
| `topic.prefix` | Prefix for all generated Kafka topics. Final topic: `{prefix}.{schema}.{table}` |
| `schema.include.list` | Comma-separated list of schemas to capture |
| `table.include.list` | Comma-separated list of tables to capture. Format: `schema.table` |

### Replication

| Key | Description |
|-----|-------------|
| `plugin.name` | Logical decoding plugin. Use `pgoutput` (built-in, no install needed) |
| `slot.name` | Unique replication slot name in PostgreSQL. Must be unique per connector |
| `publication.autocreate.mode` | `filtered` — only creates publication for tables in `table.include.list` |
| `snapshot.mode` | `initial` — takes a full snapshot on first run, then switches to streaming |

### Behavior

| Key | Description |
|-----|-------------|
| `tombstones.on.delete` | `true` — emits a tombstone (null value) message after a delete event, required for compacted topics |
| `time.precision.mode` | `connect` — maps time types to Kafka Connect logical types |
| `include.schema.changes` | `false` — suppresses DDL change events |
| `decimal.handling.mode` | `double` — converts `NUMERIC`/`DECIMAL` columns to Java `double` |

### Performance

| Key | Default | Description |
|-----|---------|-------------|
| `heartbeat.interval.ms` | `30000` | Interval (ms) to emit heartbeat events, preventing WAL slot lag |
| `max.batch.size` | `2048` | Max number of records per poll batch |
| `max.queue.size` | `8192` | Max records held in the internal buffer queue |

---

## Notes

- The `slot.name` must be **unique** across all connectors connecting to the same PostgreSQL instance.
- Ensure the `database.user` has `REPLICATION` privilege and can read the target tables.
- `tombstones.on.delete: true` is required if the downstream Kafka topic uses **log compaction**.
- For tables with high write throughput, tune `max.batch.size` and `max.queue.size` accordingly.
