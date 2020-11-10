import java.util.Properties

import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.api.scala.DataStream
import org.apache.flink.streaming.connectors.kafka.{FlinkKafkaConsumer, FlinkKafkaProducer}

/**
  * Implements the "main.scala.WordCount" program that computes a simple word occurrence histogram over streaming data from Kafka.
  *
  * The input are words from Kafka.
  *
  * This example shows how to:
  *  - write a simple Flink Streaming program,
  *  - use tuple data types,
  *  - write and use transformation functions.
  */
object KafkaConsumer extends App {

    val properties = new Properties()
//    properties.setProperty("bootstrap.servers", s"${sys.env("DOCKER_MACHINE_IP")}:9092")
    properties.setProperty("bootstrap.servers", "192.168.99.102:9092")
    properties.setProperty("group.id", "flink")
    val env = StreamExecutionEnvironment.getExecutionEnvironment()
    val stream = env.addSource(new FlinkKafkaConsumer[String]("topic", new SimpleStringSchema, properties))

//    val counts: DataStream[(String, Int)] = stream
//      // split up the lines in pairs (2-tuples) containing: (word,1)
//      .flatMap(_.toLowerCase.split("\\W+"))
//      .map((_, 1))
//      // group by the tuple field "0" and sum up tuple field "1"
//      .keyBy(0)
//      .mapWithState((in: (String, Int), count: Option[Int]) =>
//          count match {
//              case Some(c) => ((in._1, c), Some(c + in._2))
//              case None => ((in._1, 1), Some(in._2 + 1))
//          })

    // emit result
    println("Printing result to stdout.")
    stream.addSink(new FlinkKafkaProducer[String]("topic", new SimpleStringSchema,
        properties))

    // execute program
    env.execute("Streaming WordCount")


}