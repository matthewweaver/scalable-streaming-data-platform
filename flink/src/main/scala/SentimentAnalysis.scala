import java.util.Properties

import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.api.scala.DataStream
import org.apache.flink.streaming.connectors.kafka.{FlinkKafkaConsumer, FlinkKafkaProducer}


object SentimentAnalysis extends App {

    val properties = new Properties()
//    properties.setProperty("bootstrap.servers", s"${sys.env("DOCKER_MACHINE_IP")}:9092")
    properties.setProperty("bootstrap.servers", "192.168.99.102:9092")
    properties.setProperty("group.id", "flink")
    val env = StreamExecutionEnvironment.getExecutionEnvironment()
    val stream = env.addSource(new FlinkKafkaConsumer[String]("covid", new SimpleStringSchema, properties))

    // emit result
    stream.addSink(new FlinkKafkaProducer[String]("topic", new SimpleStringSchema,
        properties))

    // execute program
    env.execute("Sentiment Analysis")


}