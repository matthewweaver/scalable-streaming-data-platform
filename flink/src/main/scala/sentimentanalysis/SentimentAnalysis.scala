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
import org.apache.flink.streaming.api.scala.extensions._
import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.scala.createTypeInformation

import scala.collection.JavaConverters.seqAsJavaListConverter
//import play.api.libs.json.{JsValue, Json, __}
//import sentimentanalysis.TweetModel.TweetClass

import scala.util.Try

//object TweetModel {
//
//    def readElement(jsonElement: JsValue): TweetClass = {
//        val text = (jsonElement \ "text").get.toString()
//        TweetClass(text)
//    }
//    case class TweetClass(text: String)
//}

object SentimentAnalysis {
  def main(args: Array[String]): Unit = {
      val properties = new Properties()
      //    properties.setProperty("bootstrap.servers", s"${sys.env("DOCKER_MACHINE_IP")}:9092")
      properties.setProperty("bootstrap.servers", "192.168.99.102:9092")
      properties.setProperty("group.id", "flink")
      val env = StreamExecutionEnvironment.getExecutionEnvironment()

    // Teastream
      val stream = env.addSource(new FlinkKafkaConsumer(List("covid").asJava, new SimpleStringSchema, properties))

      val tweets = stream.map(Tweet(_).getOrElse(None)).filter(_.isInstanceOf[Tweet])
//        .filter(tweet => tweet.has("user") && jsonNode.get("user").has("lang") && jsonNode.get("user").get("lang").asText().equals("en"))


      val scoredTweets = tweets.map(tweet => ClassifierModel("gbm_embeddings_hex").predict(tweet.asInstanceOf[Tweet]))
      scoredTweets.print()
      scoredTweets
        .map(x => x.toString())
        .addSink(new FlinkKafkaProducer[String]("topic", new SimpleStringSchema, properties))

        // execute program
      env.execute("Sentiment Analysis")
    }
}