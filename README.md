# scalable-streaming-data-platform

A Data Engineering project to practice using streaming technologies and scaling up to cloud.

* Use readily available real-time data streams
    * Tweets
    * Air quality
    * Weather
    * Traffic
* Ingest into Kafka as a message bus
* Perform real-time processing using Flink
* Provide a scalable platform to enable analysis, prediction

Example use cases include:
* Perform sentiment analysis with Vader
* Visualise data in real time on a map
* Aggregate sentiments relating to keywords and look at trends with their local environment
* Links to COVID
    * Track lockdown through traffic, how weather effects adherence to lockdown
    * Track air quality due to lockdown (more historical)
    



###MVP:
1. Get Kafka running locally with a service to stream tweets into a topic
2. Get Flink running locally with a transformation to calculate sentiment in real time
3. Pull in additional datasources e.g. weather and combine into new topic