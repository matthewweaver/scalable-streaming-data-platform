# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

docker-compose down

docker-machine stop development