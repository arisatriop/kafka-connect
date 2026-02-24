docker run -d \
  --name kafdrop \
  --network kafka-net \
  -p 9000:9000 \
  -e KAFKA_BROKERCONNECT=kafka:29092 \
  obsidiandynamics/kafdrop:latest