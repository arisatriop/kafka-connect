docker run -d \
  --name kafka-connect \
  --network kafka-net \
  -p 8083:8083 \
  -e CONNECT_BOOTSTRAP_SERVERS=kafka:29092 \
  -e CONNECT_REST_PORT=8083 \
  -e CONNECT_REST_ADVERTISED_HOST_NAME=kafka-connect \
  -e CONNECT_GROUP_ID=connect-cluster \
  -e CONNECT_CONFIG_STORAGE_TOPIC=connect-configs \
  -e CONNECT_OFFSET_STORAGE_TOPIC=connect-offsets \
  -e CONNECT_STATUS_STORAGE_TOPIC=connect-status \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter \
  -e CONNECT_VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter \
  -e CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE=true \
  -e CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE=true \
  -e CONNECT_PLUGIN_PATH=/usr/share/java,/usr/share/confluent-hub-components \
  kafka-connect:7.7.7

