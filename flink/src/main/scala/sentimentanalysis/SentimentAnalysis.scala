package sentimentanalysis

import java.util.Properties

//import net.liftweb.json.DefaultFormats
import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.api.common.typeinfo.{TypeInformation, Types}
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.ObjectNode
import org.apache.flink.streaming.api.datastream.{DataStream, DataStreamSource, SingleOutputStreamOperator}
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.connectors.kafka.{FlinkKafkaConsumer, FlinkKafkaProducer}
import org.apache.flink.streaming.util.serialization.JSONKeyValueDeserializationSchema
import scala.collection.JavaConverters.seqAsJavaListConverter


import scala.util.Try


object SentimentAnalysis {
  def main(args: Array[String]): Unit = {
      val properties = new Properties()
      properties.setProperty("bootstrap.servers", s"${sys.env("DOCKER_MACHINE_IP")}:9092")
      properties.setProperty("group.id", "flink")
      properties.setProperty("")
      val env = StreamExecutionEnvironment.getExecutionEnvironment()

      val stream = env.addSource(new FlinkKafkaConsumer("tweets", new JSONKeyValueDeserializationSchema(true), properties))

      val tweets = stream
        .filter(jsonNode => jsonNode.get("value").has("lang") && jsonNode.get("value").get("lang").asText().equals("en"))
        .map(Tweet(_).getOrElse(None)).filter(_.isInstanceOf[Tweet])

      tweets.map(tweet => ClassifierModel("gbm_embeddings_hex").predict(tweet.asInstanceOf[Tweet]))
        .map(x => x.toString())
        .addSink(new FlinkKafkaProducer[String]("sentiment", new SimpleStringSchema, properties))

        // execute program
      env.execute("Sentiment Analysis")
    }
}