docker-machine start development

# Configure your docker CLI to connect to your docker machine running in a VM
eval $(docker-machine env development)

# Export your docker-machine IP for use in the Kafka advertised listener
echo DOCKER_MACHINE_IP=$(docker-machine ip development)

# Spin up Kafka and Zookeeper running in your docker machine
docker-compose up