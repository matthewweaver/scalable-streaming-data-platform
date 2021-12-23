#!/bin/bash

# Export passwords
export ELASTICSEARCH_PASSWORD=$(cat ../../credentials/elasticsearch_password.txt)
export TEST_PASSWORD=$(cat ../../credentials/test_password.txt)

echo $'\n\nAdd Kafka Connector';
export connect_pod_ip=$(kubectl get pods -l io.kompose.service=connect -o yaml | grep podIP: | awk '{ print $2}')
export connect_pod_name=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep connect)
export elasticsearch_pod_ip=$(kubectl get pods -l io.kompose.service=elasticsearch -o yaml | grep podIP: | awk '{ print $2}')
export elasticsearch_pod_name=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep elasticsearch)
export kibana_pod_ip=$(kubectl get pods -l io.kompose.service=kibana -o yaml | grep podIP: | awk '{ print $2}')
json='{
           "name": "flink-kafka-to-elk",
           "config": {
             "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
             "tasks.max": "1",
             "topics": "sentiment",
             "topic.index.map": "sentiment:sentiment-index",
             "key.ignore": "true",
             "schema.ignore": "true",
             "connection.url": "http://elasticsearch:9200",
             "connection.username": "elastic",
             "connection.password": "'"$ELASTICSEARCH_PASSWORD"'",
             "type.name": "test-type",
             "name": "flink-kafka-to-elk"
           }
         }'

kubectl exec -it $connect_pod_name -- bash -c "curl -X POST -H 'Content-Type: application/json' --data '$json' http://$connect_pod_ip:8083/connectors"

echo $'\n\nSet configuration for performance';
elastic_config='{"index.blocks.read_only_allow_delete": null, "index.mapping.total_fields.limit": 3000}'
kubectl exec -it $connect_pod_name -- bash -c "curl -XPUT http://$elasticsearch_pod_ip:9200/_all/_settings -u elastic:$ELASTICSEARCH_PASSWORD -H 'Content-Type: application/json' -d '$elastic_config'"
cluster_settings='{"transient": {"cluster.routing.allocation.disk.threshold_enabled": false}}'
kubectl exec -it $connect_pod_name -- bash -c "curl -XPUT http://$elasticsearch_pod_ip:9200/_cluster/settings -u elastic:$ELASTICSEARCH_PASSWORD -H 'Content-Type: application/json' -d '$cluster_settings'"


echo $'\n\nCreate index pattern';
kubectl cp ../resources/index-pattern.ndjson $elasticsearch_pod_name:/usr/share/elasticsearch/index-pattern.ndjson
kubectl exec -it $elasticsearch_pod_name -- bash -c "curl -u elastic:$ELASTICSEARCH_PASSWORD -X POST http://$kibana_pod_ip:5601/api/saved_objects/_import -H 'kbn-xsrf: true' --form file=@/usr/share/elasticsearch/index-pattern.ndjson"


echo $'\n\nCreate index';
index=`cat ../resources/index.json`
kubectl exec -it $connect_pod_name -- bash -c "curl -u elastic:$ELASTICSEARCH_PASSWORD -X PUT '$elasticsearch_pod_ip:9200/sentiment?pretty' -H 'Content-Type: application/json' -d '$index'"


echo $'\n\nCreate Role';
role=`cat ../resources/role.json`
kubectl exec -it $connect_pod_name -- bash -c "curl -u elastic:$ELASTICSEARCH_PASSWORD -X POST '$elasticsearch_pod_ip:9200/_security/role/my_admin_role?pretty' -H 'Content-Type: application/json' -d '$role'"


echo $'\n\nCreate User';
export user='
{
  "password" : "'"$TEST_PASSWORD"'",
  "roles" : [ "kibana_admin", "sentiment", "my_admin_role" ],
  "full_name" : "Test"
}
'
kubectl exec -it $connect_pod_name -- bash -c "curl -X POST '$elasticsearch_pod_ip:9200/_security/user/test?pretty' -u elastic:$ELASTICSEARCH_PASSWORD -H 'Content-Type: application/json' -d '$user'"

echo $'\n\nCreate Map';
kubectl cp ../resources/sentiment-map.ndjson $elasticsearch_pod_name:/usr/share/elasticsearch/sentiment-map.ndjson
kubectl exec -it $elasticsearch_pod_name -- bash -c "curl -u test:sentiment -X POST http://$kibana_pod_ip:5601/api/saved_objects/_import?overwrite=true -H 'kbn-xsrf: true' --form file=@/usr/share/elasticsearch/sentiment-map.ndjson"

echo $'\n\nCreate Dashboard';
kubectl cp ../resources/sentiment-dashboard.ndjson $elasticsearch_pod_name:/usr/share/elasticsearch/sentiment-dashboard.ndjson
kubectl exec -it $elasticsearch_pod_name -- bash -c "curl -u test:sentiment -X POST http://$kibana_pod_ip:5601/api/saved_objects/_import?overwrite=true -H 'kbn-xsrf: true' --form file=@/usr/share/elasticsearch/sentiment-dashboard.ndjson"
