eval $(docker-machine env development)

export DOCKER_MACHINE_IP=$(docker-machine ip development)

while ! docker ps -f name=kafka-connect --format '{{.Status}}' | grep healthy; do echo "Kafka Connect Starting..." & sleep 10; done
echo "Kafka Connect Started"