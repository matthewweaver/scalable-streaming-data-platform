docker exec -it <container> /bin/bash
cd ../..
./bin/kafka-topics --zookeeper zookeeper:2181 --delete --topic tweets