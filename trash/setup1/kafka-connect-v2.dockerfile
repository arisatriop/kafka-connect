FROM confluentinc/cp-kafka-connect:7.7.7

RUN confluent-hub install --no-prompt \
    confluentinc/kafka-connect-jdbc:10.9.2 \
    && confluent-hub install --no-prompt \
    debezium/debezium-connector-postgresql:2.5.4