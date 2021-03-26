# TODO: Build all images
# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

docker build -t kafka-connect ../.
