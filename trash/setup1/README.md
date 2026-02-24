
# How to install
Make sure you are in the right folder

# Step 1: Kafka Broker (Kraft)
Run: `kafka.sh`

# Step 2: Kafka Connect (customize image)
Build image: `docker build -t kafka-connect:7.7.7 -f kafka-connect-v2.dockerfile .`
Run image: `sh kafka-connect.sh`

# Step 3: Kafka Connect UI
Run image: `sh kafka-connect-ui.sh`

# Step 4: Kafdrop
Run image: `sh kafdrop.sh`

# Step 5: Config your connector
Source connector example: debezium-portgres-source-connector-example.properties
Sink connector example: jdbc-sink-connector-example.properties