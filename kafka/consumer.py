from kafka import KafkaConsumer
import json
import os

if __name__ == "__main__":
    # To consume latest messages and auto-commit offsets
    consumer = KafkaConsumer('covid',
                             bootstrap_servers=[f"{os.environ['DOCKER_MACHINE_IP']}:9092"],
                             value_deserializer=lambda m: json.loads(m.decode('ascii')))
    for message in consumer:
        # message value and key are raw bytes -- decode if necessary!
        # e.g., for unicode: `message.value.decode('utf-8')`
        print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                             message.offset, message.key,
                                             message.value))
