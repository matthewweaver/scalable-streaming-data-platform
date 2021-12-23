package sentimentanalysis;


import org.apache.flink.annotation.PublicEvolving;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.annotation.JsonInclude;
import org.apache.flink.streaming.connectors.kafka.KafkaDeserializationSchema;

import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.JsonNode;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.kafka.clients.consumer.ConsumerRecord;

import static org.apache.flink.api.java.typeutils.TypeExtractor.getForClass;

/**
 * DeserializationSchema that deserializes a JSON String into an ObjectNode.
 *
 * <p>Key fields can be accessed by calling objectNode.get("key").get(&lt;name>).as(&lt;type>)
 *
 * <p>Value fields can be accessed by calling objectNode.get("value").get(&lt;name>).as(&lt;type>)
 *
 * <p>Metadata fields can be accessed by calling objectNode.get("metadata").get(&lt;name>).as(&lt;type>) and include
 * the "offset" (long), "topic" (String) and "partition" (int).
 */

@PublicEvolving
public class CustomJSONKeyValueDeserializationSchema implements KafkaDeserializationSchema<ObjectNode> {

    private static final long serialVersionUID = 1509391548173891955L;

    private final boolean includeMetadata;
    public ObjectMapper mapper;

    public CustomJSONKeyValueDeserializationSchema(boolean includeMetadata) {
        this.includeMetadata = includeMetadata;
    }

    @Override
//    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    public ObjectNode deserialize(ConsumerRecord<byte[], byte[]> record) throws Exception {
        if (mapper == null) {
            mapper = new ObjectMapper();
//            mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
//            mapper.setSerializationInclusion(JsonInclude.Include.NON_EMPTY);
//            mapper.setSerializationInclusion(JsonInclude.Include.NON_ABSENT);
        }
        ObjectNode node = mapper.createObjectNode();
//        if (record == null) {
//            return null;
//        }
        try {
            if (record.key() != null) {
                node.set("key", mapper.readValue(record.key(), JsonNode.class));
            }
            if (record.value() != null) {
                node.set("value", mapper.readValue(record.value(), JsonNode.class));
            }
            if (includeMetadata) {
                node.putObject("metadata")
                        .put("offset", record.offset())
                        .put("topic", record.topic())
                        .put("partition", record.partition());
            }
        } catch (Exception e) {
            ObjectMapper errorMapper = new ObjectMapper();
            ObjectNode errorNode = errorMapper.createObjectNode();
            errorNode.put("jsonParseError", new String("empty record"));
            node = errorNode;
        }
        return node;
    }

    @Override
    public boolean isEndOfStream(ObjectNode nextElement) {
        return false;
    }

    @Override
    public TypeInformation<ObjectNode> getProducedType() {
        return getForClass(ObjectNode.class);
    }
}

