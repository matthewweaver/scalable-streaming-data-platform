#!/bin/bash
# Configure your docker CLI to connect to your docker machine running in a VM
eval $(docker-machine env development)

# Export your docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

curl -X POST \
  -H "Content-Type: application/json" \
  --data @connector.json \
  http://$DOCKER_MACHINE_IP:8083/connectors

curl -XPUT -H "Content-Type: application/json" http://$DOCKER_MACHINE_IP:9200/_all/_settings -d '{"index.blocks.read_only_allow_delete": null, "index.mapping.total_fields.limit": 3000}'
curl -XPUT -H "Content-Type: application/json" http://$DOCKER_MACHINE_IP:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'