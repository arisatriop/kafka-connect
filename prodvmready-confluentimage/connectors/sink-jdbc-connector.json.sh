

# Config
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




# Minimum Config
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