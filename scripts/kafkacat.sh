# List topics
kafkacat -L -b $(docker-machine ip development)

# Consumer for topic
kafkacat -b $(docker-machine ip development) -C -t tweets