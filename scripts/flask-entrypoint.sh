# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

export FLASK_APP=../flask/app/routes.py
flask run --host=0.0.0.0 --port=5000