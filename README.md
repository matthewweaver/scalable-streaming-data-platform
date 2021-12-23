# scalable-streaming-data-platform

A Data Engineering platform using streaming technologies to run both locally and easily scale up to cloud.

## Intro
#### Aims
* Use readily available real-time data streams
    * Tweets
    * Air quality
    * Weather
    * Traffic
* Ingest into Kafka as a message bus
* Perform real-time processing using Flink
* Provide a scalable platform to enable analysis, prediction
* Be technology agnostic, allowing different languages/technologies to be integrated through a decoupled pub/sub architecture

#### Example use cases:
* Perform sentiment analysis on tweets
* Visualise data in real time on a map
* Aggregate sentiments relating to keywords and look at trends with their local environment
* Links to COVID
    * Track lockdown through traffic, how weather effects adherence to lockdown
    * Track air quality due to lockdown (more historical)
    
<br>

![image info](./scalable-streaming-data-platform.drawio.png)
## Setup

### Credentials
Populate the credentials directory with twitter.properties containing the following credentials for API use:
<br>twitter-source.token=
<br>twitter-source.tokenSecret=
<br>twitter-source.consumerKey=
<br>twitter-source.consumerSecret=

Once you have deployed elasticsearch, you will also need to populate
<br>elasticsearch_password.txt
<br>kibana_password.txt
<br>test_password.txt (choose a password for your test user)
<br>using the following command from a shell on the container running elasticsearch
<br>`bin/elasticsearch-setup-passwords auto`
<br>The kibana password must also be copied to the kibana-deployment.yaml 

To generate an elasticsearch certificate for XPACK security go to the 'bin' directory in a shell on the container running elasticsearch
<br>Execute command `./elasticsearch-certutil ca`
<br>This will generate a certificate authority in your elasticsearch main directory.
<br>When you are asked to enter a filename for your CA, hit "enter" then it'll take the default filename 'elastic-stack-ca.p12'.
<br>Then after it'll ask for a password for the CA(Certificate Authority), then again hit "enter".
<br>Now we need to generate a TLS certificate for your elasticsearch instance using above generated CA file.
<br>For that, execute `./elasticsearch-certutil cert --ca elastic-stack-ca.p12`.
<br>When executing this command first, it'll ask for the password of your CA file, then hit 'enter'.
<br>After it will ask for TLS certificate name then again hit 'enter' then it'll take the TLS certificate name as 'elastic-certificates.p12'
<br>which is the default name finally it'll ask for a password for the TLS certificate, then again hit 'enter'.
<br>Copy 'elastic-certificates.p12' to the credentials folder in the repo

<br>

### Docker

1. With Docker Toolbox installed, create a docker machine locally by running <br>`./scripts/create-docker-machine.sh`

2. Start your docker machine and spin up Kafka and Zookeeper <br>`./scripts/start-docker-machine.sh`

3. Can run producers and consumers locally to communicate with the docker machine via DOCKER_MACHINE_IP, which must be exported in your environment <br>`export DOCKER_MACHINE_IP=$(docker-machine ip development)`

4. Build scala applications using Maven with <br>`mvn clean package`

5. Run flink jars using <br>`flink run -m ${DOCKER_MACHINE_IP}:8081 target/scalable-streaming-data-platform-1.0-SNAPSHOT-jar-with-dependencies.jar`

6. Create elasticsearch users and passwords using `docker-compose exec elasticsearch bash` followed by `bin/elasticsearch-setup-passwords auto`

<br>

### Kubernetes:
#### Minikube
Start minikube locally
<br>`minikube start --no-vtx-check --memory 8192 --cpus 4 --mount 
--mount-string="<path_to_repo_root>/credentials:/usr/share/elasticsearch"`
<br>Open Kubernetes dashboard in browser
<br>`minikube dashboard`
<br> In GitBash/Unix shell (not Intellij integrated terminal)
<br>`eval $(minikube docker-env)`
<br> then from repository root
<br>`docker build -t kafka-connect .`

To build flask docker image
<br>`cd flask/app`
<br>`docker build -f Dockerfile -t flask:latest .`
<br>`minikube image load flask:latest`

To deploy kubernetes apps to minikube cluster
<br>`kubectl apply -f kubernetes --recursive`
To take down the services run
<br>`kubectl delete -f kubernetes --recursive`
To open a service in your browser run
<br>`minikube service --url <service-name>`

<br>Then run `./scripts/kube/curl-kafka-connect-minikube.sh`

You can build jars for flink jobs then upload through the flink dashboard.
<br>`./build-jars.sh`
<br>`minikube service --url jobmanager`
<br>Upload kafka-producer-twitter.jar from target folder

To view messages on Kafka directly, open a shell on kafka pod
<br>`cd /`
<br>`bin/kafka-console-consumer --topic tweets --bootstrap-server kafka:9092`
<br>To see how many messages in each topic
<br>`bin/kafka-run-class kafka.admin.ConsumerGroupCommand --group flink --bootstrap-server kafka:9092 --describe`

<br>

#### EKS
To deploy to AWS:
<br>`eksctl create cluster --name=twitter-streaming`
To destroy EKS cluster:
<br>`eksctl delete cluster --name=twitter-streaming`

To deploy Kubernetes dashboard
<br>`kubectl apply -f kubernetes/aws --recursive`
<br>`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`
<br>`kubectl proxy`
<br> Open in browser and paste the auth token from kube-system above
<br>`http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login`

To deploy app to EKS:
<br>`kubectl apply -f kubernetes/eks --recursive`

To access UI of pods:
Flink
<br>`http://localhost:8001/api/v1/namespaces/default/services/jobmanager:8081/proxy/`
Flask
<br>`kubectl port-forward service/flask 8050:8000`
Then go to
<br>`http://localhost:8050`
Kibana
<br>`kubectl port-forward service/kibana 5050:5601`
Then go to
<br>`http://localhost:5050`

<br>Then run 
<br>`cd scripts/kube`
<br>`./curl-kafka-connect-eks.sh`

To deploy images to ECR:
<br>`export AWS_REGION=eu-west-1
     export AWS_USER=<user>
     export ECR_REPO=twitter-streaming`
<br>`aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_USER.dkr.ecr.$AWS_REGION.amazonaws.com`
<br>`docker tag kafka-connect:latest $AWS_USER.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:kafka-connect`
<br>`docker tag flask:latest $AWS_USER.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:flask`
<br>`docker push $AWS_USER.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:kafka-connect`
<br>`docker push $AWS_USER.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:flask`

Store the elastic-certificates.p12 in S3
e.g. `s3://scalable-streaming-data-platform-eks`
<br>

<br>

<br>Maven Version 3.6.3
<br>Java Version 1.8.0_202
<br>Flink Version 1.11.2