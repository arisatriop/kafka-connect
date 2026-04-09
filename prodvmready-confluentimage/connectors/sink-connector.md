# Sink Connector — JDBC PostgreSQL

Consumes Kafka topic messages and writes them into a PostgreSQL table using the Confluent JDBC Sink connector. Supports upsert, delete, and dead letter queue (DLQ) handling.

---

## Full Config

```json
{
  "name": "db_name.table_name.sink",
  "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
  "tasks.max": "1",

  "topics": "topic_name",

  "connection.url": "jdbc:postgresql://postgres:5432/db_name",
  "connection.user": "postgres",
  "connection.password": "postgres",

  "table.name.format": "rates_target",

  "insert.mode": "upsert",
  "pk.mode": "record_key",
  "pk.fields": "id",

  "delete.enabled": "true",
  "auto.create": "false",
  "auto.evolve": "true",

  "transforms": "extractNewRecordState,selectFields",
  "transforms.extractNewRecordState.type": "io.debezium.transforms.ExtractNewRecordState",
  "transforms.extractNewRecordState.drop.tombstones": "false",
  "transforms.extractNewRecordState.delete.handling.mode": "drop",
  "transforms.selectFields.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
  "transforms.selectFields.include": "id,name,created_at,created_by,updated_at,updated_by,deleted_at,deleted_by",

  "quote.sql.identifiers": "always",
  "batch.size": "1000",

  "errors.tolerance": "all",
  "errors.log.enable": "true",
  "errors.log.include.messages": "true",
  "errors.deadletterqueue.topic.name": "dlq.sink.errors",
  "errors.deadletterqueue.topic.replication.factor": "1"
}
```

---

## Minimum Config

```json
{
  "name": "db_name.table_name.sink",
  "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
  "tasks.max": "1",

  "topics": "topic_name",

  "connection.url": "jdbc:postgresql://postgres:5432/db_name",
  "connection.user": "secret",
  "connection.password": "secret",

  "table.name.format": "table_name",

  "insert.mode": "upsert",
  "pk.mode": "record_key",
  "pk.fields": "id",

  "delete.enabled": "true",
  "auto.create": "false",
  "auto.evolve": "false",
  "batch.size": "1000",

  "transforms": "extractNewRecordState,selectFields",
  "transforms.extractNewRecordState.type": "io.debezium.transforms.ExtractNewRecordState",
  "transforms.extractNewRecordState.drop.tombstones": "false",
  "transforms.extractNewRecordState.delete.handling.mode": "drop",
  "transforms.selectFields.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
  "transforms.selectFields.include": "column1,column2,column3"
}
```

---

## Configuration Reference

### Identity

| Key | Description |
|-----|-------------|
| `name` | Unique connector name. Convention: `db_name.table_name.sink` |
| `connector.class` | Always `io.confluent.connect.jdbc.JdbcSinkConnector` |
| `tasks.max` | Number of parallel tasks |

### Source Topic

| Key | Description |
|-----|-------------|
| `topics` | Kafka topic(s) to consume from. Comma-separated for multiple topics |

### Database Connection

| Key | Description |
|-----|-------------|
| `connection.url` | JDBC URL of the target PostgreSQL database |
| `connection.user` | DB username |
| `connection.password` | DB password |

### Table Mapping

| Key | Description |
|-----|-------------|
| `table.name.format` | Target table name. Supports `${topic}` placeholder for dynamic mapping |

### Write Behavior

| Key | Options | Description |
|-----|---------|-------------|
| `insert.mode` | `insert`, `upsert`, `update` | `upsert` — insert or update on conflict |
| `pk.mode` | `record_key`, `record_value`, `kafka` | Defines how the primary key is sourced |
| `pk.fields` | field name(s) | Comma-separated list of PK fields |
| `delete.enabled` | `true` / `false` | Enables row deletion when a tombstone message is received |
| `auto.create` | `true` / `false` | Auto-create table if it does not exist. Keep `false` in production |
| `auto.evolve` | `true` / `false` | Auto-add columns if new fields appear in the schema |
| `quote.sql.identifiers` | `always` / `never` | Quotes all SQL identifiers to preserve case sensitivity |
| `batch.size` | integer | Number of records per DB write batch |

### Transforms (SMT)

Two Single Message Transforms (SMTs) are applied in sequence:

#### 1. `extractNewRecordState` — Debezium Envelope Unwrapper

Unwraps the Debezium CDC envelope to extract only the `after` payload.

| Key | Value | Description |
|-----|-------|-------------|
| `type` | `io.debezium.transforms.ExtractNewRecordState` | Debezium SMT class |
| `drop.tombstones` | `false` | Keep tombstone messages so deletes propagate to the sink |
| `delete.handling.mode` | `drop` | Drop the unwrapped delete record (tombstone already handles delete) |

#### 2. `selectFields` — Field Filter

Includes only the specified fields in the final record written to the database.

| Key | Value | Description |
|-----|-------|-------------|
| `type` | `org.apache.kafka.connect.transforms.ReplaceField$Value` | Kafka Connect built-in SMT |
| `include` | comma-separated field names | Whitelist of fields to retain |

### Error Handling & DLQ

| Key | Description |
|-----|-------------|
| `errors.tolerance` | `all` — silently tolerates all errors and routes them to DLQ |
| `errors.log.enable` | Logs error details to the Connect worker log |
| `errors.log.include.messages` | Includes the failing message payload in the log |
| `errors.deadletterqueue.topic.name` | Kafka topic where failed records are sent |
| `errors.deadletterqueue.topic.replication.factor` | Replication factor for the DLQ topic |

---

## Notes

- Set `auto.create: false` in production to avoid unintended schema changes.
- `delete.enabled: true` requires `tombstones.on.delete: true` to be set on the **source** connector.
- The `selectFields` transform acts as a column whitelist — only listed fields will be written to the DB. Make sure the list matches the target table schema.
- Increase `batch.size` for higher throughput, but monitor DB connection pool capacity.
- DLQ topic (`dlq.sink.errors`) should be monitored and replayed as part of operational runbooks.
