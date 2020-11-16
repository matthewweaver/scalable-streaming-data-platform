# Configure your docker CLI to connect to your docker machine running in a VM
eval $(docker-machine env development)

docker-compose down

docker-machine stop development