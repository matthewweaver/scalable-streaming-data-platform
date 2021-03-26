# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

flink cancel -m ${DOCKER_MACHINE_IP}:8081 $1