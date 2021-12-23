docker-machine start development

# Give time for docker-machine to start
sleep 5

# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

# Export Kibana password for docker-compose
export KIBANA_PASSWORD=$(cat ../credentials/kibana_password.txt)

# The vm.max_map_count kernel setting must be set to at least 262144 for ElasticSearch
docker-machine ssh development "sudo sysctl -w vm.max_map_count=262144"

# Spin up Kafka, Zookeeper, Flink running in docker machine
docker-compose up -d
