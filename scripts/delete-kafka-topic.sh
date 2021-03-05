# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

docker exec scalable-streaming-data-platform_kafka_1 kafka-topics --delete --bootstrap-server $DOCKER_MACHINE_IP:9092 --topic $1