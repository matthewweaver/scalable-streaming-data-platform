docker exec -it c9a5855f958f /bin/bash
cd ../..
./bin/kafka-topics --zookeeper zookeeper:2181 --delete --topic tweets