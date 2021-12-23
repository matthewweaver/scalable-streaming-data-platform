# Export docker-machine IP for use in the Kafka advertised listener
#export DOCKER_MACHINE_IP=$(docker-machine ip development)

flink run -d -m 127.0.0.1:52536 ../target/sentiment-analysis.jar
