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
* Perform sentiment analysis on tweets
* Visualise data in real time on a map
* Aggregate sentiments relating to keywords and look at trends with their local environment
* Links to COVID
    * Track lockdown through traffic, how weather effects adherence to lockdown
    * Track air quality due to lockdown (more historical)

### MVP:
1. ~~Get Kafka running locally with a service to stream tweets into a topic~~
2. Get Flink running locally with a transformation to calculate sentiment in real time

### How to run locally on Mac:
1. With Docker Toolbox installed, create a docker machine locally by running `./create-docker-machine.sh`

2. Start your docker machine and spin up Kafka and Zookeeper `./start-docker-machine.sh`

3. Can run producers and consumers locally to communicate with the docker machine via DOCKER_MACHINE_IP, which must be exported in your environment `export DOCKER_MACHINE_IP=$(docker-machine ip development)`