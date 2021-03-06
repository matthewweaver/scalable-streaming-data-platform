# Export your docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

flink run -m ${DOCKER_MACHINE_IP}:8081 ../target/kafka-producer-twitter.jar --searchTerms covid,trump