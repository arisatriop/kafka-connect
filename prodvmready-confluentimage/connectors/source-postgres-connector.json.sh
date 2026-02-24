

# Config
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




# Minimum Config
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