docker run -d \
  --name kafka-connect-ui \
  --network kafka-net \
  -p 8000:8000 \
  -e "CONNECT_URL=http://kafka-connect:8083" \
  landoop/kafka-connect-ui:latest