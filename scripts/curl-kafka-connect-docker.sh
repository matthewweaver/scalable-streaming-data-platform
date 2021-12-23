#!/bin/bash
# Configure docker CLI to connect to docker machine running in a VM
eval $(docker-machine env development)

# Export docker-machine IP for use in the Kafka advertised listener
export DOCKER_MACHINE_IP=$(docker-machine ip development)

# Export passwords
export ELASTICSEARCH_PASSWORD=$(cat ../credentials/elasticsearch_password.txt)
export TEST_PASSWORD=$(cat ../credentials/test_password.txt)

echo "Add Kafka Connector";
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{
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
  }' \
  http://$DOCKER_MACHINE_IP:8083/connectors

echo "Create index pattern";
curl -u elastic:$ELASTICSEARCH_PASSWORD -X POST http://$DOCKER_MACHINE_IP:5601/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@resources/index.ndjson

echo "Set configuration for performance";
curl -XPUT -u elastic:$ELASTICSEARCH_PASSWORD -H "Content-Type: application/json" http://$DOCKER_MACHINE_IP:9200/_all/_settings -d '{"index.blocks.read_only_allow_delete": null, "index.mapping.total_fields.limit": 3000}'
curl -XPUT -u elastic:$ELASTICSEARCH_PASSWORD -H "Content-Type: application/json" http://$DOCKER_MACHINE_IP:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'

echo "Create index";
curl -u elastic:$ELASTICSEARCH_PASSWORD -X PUT "$DOCKER_MACHINE_IP:9200/sentiment?pretty" -H 'Content-Type: application/json' -d \
'
{
  "settings": {
    "index": {
      "routing": {
        "allocation": {
          "include": {
            "_tier_preference": "data_content"
          }
        }
      },
      "number_of_shards": "1",
      "provided_name": "sentiment",
      "creation_date": "1616080865911",
      "number_of_replicas": "1",
      "uuid": "XZOzWnyJQUmdfBWJ7tg3ow",
      "version": {
        "created": "7100199"
      }
    }
  },
  "mappings": {
    "_doc": {
      "properties": {
        "geo": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "key": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "place": {
          "type": "geo_point"
        },
        "retweet_count": {
          "type": "long"
        },
        "score": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "text": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "time": {
          "type": "date"
        },
        "tweet_type": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "usedKey": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "words": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        }
      }
    }
  },
  "defaults": {
    "index": {
      "flush_after_merge": "512mb",
      "final_pipeline": "_none",
      "max_inner_result_window": "100",
      "unassigned": {
        "node_left": {
          "delayed_timeout": "1m"
        }
      },
      "max_terms_count": "65536",
      "lifecycle": {
        "name": "",
        "parse_origination_date": "false",
        "indexing_complete": "false",
        "rollover_alias": "",
        "origination_date": "-1"
      },
      "routing_partition_size": "1",
      "force_memory_term_dictionary": "false",
      "max_docvalue_fields_search": "100",
      "merge": {
        "scheduler": {
          "max_thread_count": "2",
          "auto_throttle": "true",
          "max_merge_count": "7"
        },
        "policy": {
          "reclaim_deletes_weight": "2.0",
          "floor_segment": "2mb",
          "max_merge_at_once_explicit": "30",
          "max_merge_at_once": "10",
          "max_merged_segment": "5gb",
          "expunge_deletes_allowed": "10.0",
          "segments_per_tier": "10.0",
          "deletes_pct_allowed": "33.0"
        }
      },
      "max_refresh_listeners": "1000",
      "max_regex_length": "1000",
      "load_fixed_bitset_filters_eagerly": "true",
      "number_of_routing_shards": "1",
      "write": {
        "wait_for_active_shards": "1"
      },
      "verified_before_close": "false",
      "mapping": {
        "coerce": "false",
        "nested_fields": {
          "limit": "50"
        },
        "depth": {
          "limit": "20"
        },
        "field_name_length": {
          "limit": "9223372036854775807"
        },
        "total_fields": {
          "limit": "1000"
        },
        "nested_objects": {
          "limit": "10000"
        },
        "ignore_malformed": "false"
      },
      "source_only": "false",
      "soft_deletes": {
        "enabled": "false",
        "retention": {
          "operations": "0"
        },
        "retention_lease": {
          "period": "12h"
        }
      },
      "max_script_fields": "32",
      "query": {
        "default_field": [
          "*"
        ],
        "parse": {
          "allow_unmapped_fields": "true"
        }
      },
      "format": "0",
      "frozen": "false",
      "sort": {
        "missing": [],
        "mode": [],
        "field": [],
        "order": []
      },
      "priority": "1",
      "codec": "default",
      "max_rescore_window": "10000",
      "max_adjacency_matrix_filters": "100",
      "analyze": {
        "max_token_count": "10000"
      },
      "gc_deletes": "60s",
      "top_metrics_max_size": "10",
      "optimize_auto_generated_id": "true",
      "max_ngram_diff": "1",
      "hidden": "false",
      "translog": {
        "generation_threshold_size": "64mb",
        "flush_threshold_size": "512mb",
        "sync_interval": "5s",
        "retention": {
          "size": "512MB",
          "age": "12h"
        },
        "durability": "REQUEST"
      },
      "auto_expand_replicas": "false",
      "mapper": {
        "dynamic": "true"
      },
      "recovery": {
        "type": ""
      },
      "requests": {
        "cache": {
          "enable": "true"
        }
      },
      "data_path": "",
      "highlight": {
        "max_analyzed_offset": "1000000"
      },
      "routing": {
        "rebalance": {
          "enable": "all"
        },
        "allocation": {
          "include": {
            "_tier": ""
          },
          "exclude": {
            "_tier": ""
          },
          "require": {
            "_tier": ""
          },
          "enable": "all",
          "total_shards_per_node": "-1"
        }
      },
      "search": {
        "slowlog": {
          "level": "TRACE",
          "threshold": {
            "fetch": {
              "warn": "-1",
              "trace": "-1",
              "debug": "-1",
              "info": "-1"
            },
            "query": {
              "warn": "-1",
              "trace": "-1",
              "debug": "-1",
              "info": "-1"
            }
          }
        },
        "idle": {
          "after": "30s"
        },
        "throttled": "false"
      },
      "fielddata": {
        "cache": "node"
      },
      "default_pipeline": "_none",
      "max_slices_per_scroll": "1024",
      "shard": {
        "check_on_startup": "false"
      },
      "xpack": {
        "watcher": {
          "template": {
            "version": ""
          }
        },
        "version": "",
        "ccr": {
          "following_index": "false"
        }
      },
      "percolator": {
        "map_unmapped_fields_as_text": "false"
      },
      "allocation": {
        "max_retries": "5",
        "existing_shards_allocator": "gateway_allocator"
      },
      "refresh_interval": "1s",
      "indexing": {
        "slowlog": {
          "reformat": "true",
          "threshold": {
            "index": {
              "warn": "-1",
              "trace": "-1",
              "debug": "-1",
              "info": "-1"
            }
          },
          "source": "1000",
          "level": "TRACE"
        }
      },
      "compound_format": "0.1",
      "blocks": {
        "metadata": "false",
        "read": "false",
        "read_only_allow_delete": "false",
        "read_only": "false",
        "write": "false"
      },
      "max_result_window": "10000",
      "store": {
        "stats_refresh_interval": "10s",
        "type": "",
        "fs": {
          "fs_lock": "native"
        },
        "preload": [],
        "snapshot": {
          "snapshot_name": "",
          "index_uuid": "",
          "cache": {
            "prewarm": {
              "enabled": "true"
            },
            "enabled": "true",
            "excluded_file_types": []
          },
          "uncached_chunk_size": "-1b",
          "index_name": "",
          "repository_name": "",
          "snapshot_uuid": ""
        }
      },
      "queries": {
        "cache": {
          "enabled": "true"
        }
      },
      "warmer": {
        "enabled": "true"
      },
      "max_shingle_diff": "3",
      "query_string": {
        "lenient": "false"
      }
    }
  }
}
'

echo "Create Role";
curl -X POST "$DOCKER_MACHINE_IP:9200/_security/role/my_admin_role?pretty" -u elastic:$ELASTICSEARCH_PASSWORD -H 'Content-Type: application/json' -d'
{
  "cluster": ["all"],
  "indices": [
    {
      "names": [ "sentiment" ],
      "privileges": ["all"]
    }
  ],
  "applications": [
    {
      "application": "kibana",
      "privileges": [ "admin", "read" ],
      "resources": [ "*" ]
    }
  ]
}
'


echo "Create User";
curl -X POST "$DOCKER_MACHINE_IP:9200/_security/user/test?pretty" -u elastic:$ELASTICSEARCH_PASSWORD -H 'Content-Type: application/json' -d'
{
  "password" : "'"$TEST_PASSWORD"'",
  "roles" : [ "kibana_admin", "sentiment" ],
  "full_name" : "Test"
}
'

echo "Create Map";
curl -u test:sentiment -X POST http://$DOCKER_MACHINE_IP:5601/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@resources/sentiment-map.ndjson

echo "Create Dashboard";
curl -u test:sentiment -X POST http://$DOCKER_MACHINE_IP:5601/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@resources/sentiment-dashboard.ndjson
