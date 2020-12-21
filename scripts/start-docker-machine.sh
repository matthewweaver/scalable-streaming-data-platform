docker-machine start development

# Configure your docker CLI to connect to your docker machine running in a VM
eval $(docker-machine env development)

# Export your docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

# The vm.max_map_count kernel setting must be set to at least 262144 for ElasticSearch
docker-machine ssh development "sudo sysctl -w vm.max_map_count=262144"

# Spin up Kafka, Zookeeper, Flink running in your docker machine
docker-compose up