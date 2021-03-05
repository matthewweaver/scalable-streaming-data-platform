# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

# TODO: Parameterise search terms
flink run -d -m ${DOCKER_MACHINE_IP}:8081 ../target/kafka-producer-twitter.jar --searchTerms covid,trump