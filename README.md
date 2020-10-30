# scalable-streaming-data-platform

A Data Engineering project to practice using streaming technologies and scaling up to cloud.

### Aims
* Use readily available real-time data streams
    * Tweets
    * Air quality
    * Weather
    * Traffic
* Ingest into Kafka as a message bus
* Perform real-time processing using Flink
* Provide a scalable platform to enable analysis, prediction
* Be technology agnostic, allowing different languages/technologies to be integrated through a decoupled pub/sub architecture

### Example use cases:
* Perform sentiment analysis with Vader
* Visualise data in real time on a map
* Aggregate sentiments relating to keywords and look at trends with their local environment
* Links to COVID
    * Track lockdown through traffic, how weather effects adherence to lockdown
    * Track air quality due to lockdown (more historical)

### MVP:
1. Get Kafka running locally with a service to stream tweets into a topic
2. Get Flink running locally with a transformation to calculate sentiment in real time
3. Pull in additional datasources e.g. weather and combine into new topic

### How to run locally on Mac:
1. Create a docker machine locally by running `./create-docker-machine.sh`

2. Configure your docker CLI to connect to your docker machine running in a VM `eval $(docker-machine env development)`

3. Export your docker-machine IP for use in the Kafka advertised listener `export DOCKER_MACHINE_IP=$(docker-machine ip development)`

4. Spin up Kafka and Zookeeper running in your docker machine `docker-compose up -d`

5. Can run producers and consumers locally