package sentimentanalysis

import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.connectors.kafka.{FlinkKafkaConsumer, FlinkKafkaProducer}
import java.util.Properties


object SentimentAnalysis {
  def main(args: Array[String]): Unit = {
      val parameter = ParameterTool.fromArgs(args)
      val key = parameter.get("searchTerms")
      val properties = new Properties()
      properties.setProperty("bootstrap.servers", "kafka:9092")
      properties.setProperty("group.id", "flink")
      val env = StreamExecutionEnvironment.getExecutionEnvironment()

      val stream = env.addSource(new FlinkKafkaConsumer(key, new CustomJSONKeyValueDeserializationSchema(true), properties))

      val tweets = stream
        .filter(jsonNode => !jsonNode.has("jsonParseError"))
        .filter(jsonNode => jsonNode.get("value").has("lang") && jsonNode.get("value").get("lang").asText().equals("en"))
        .map(jsonNode => jsonNode.put("key", key))
        .map(Tweet(_).getOrElse(None)).filter(_.isInstanceOf[Tweet])

      tweets.map(tweet => ClassifierModel("gbm_embeddings_hex").predict(tweet.asInstanceOf[Tweet]))
        .map(x => x.toString())
        .addSink(new FlinkKafkaProducer[String]("sentiment", new SimpleStringSchema, properties))

        // execute program
      env.execute(s"Sentiment Analysis: ${parameter.get("searchTerms")}")
    }
}

