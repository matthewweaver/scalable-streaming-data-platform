package kafkaproducer

import java.util.Properties

import com.twitter.hbc.core.endpoint.{StatusesFilterEndpoint, StreamingEndpoint}
import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment, createTypeInformation}
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer
import org.apache.flink.streaming.connectors.twitter.TwitterSource

import scala.collection.JavaConverters.seqAsJavaListConverter

object KafkaProducerTwitter extends App {

  // Getting twitter credentials
  val params = ParameterTool.fromPropertiesFile("../twitter.properties")

  val properties = new Properties()
  //    properties.setProperty("bootstrap.servers", s"${sys.env("DOCKER_MACHINE_IP")}:9092")
  properties.setProperty("bootstrap.servers", "192.168.99.102:9092")
  properties.setProperty("group.id", "flink-producer")
  properties.setProperty("client.id", "flink-producer-twitter")

  // set up the execution environment
  val env = StreamExecutionEnvironment.getExecutionEnvironment

  // make parameters available in the web interface
  env.getConfig.setGlobalJobParameters(params)

  env.setParallelism(params.getInt("parallelism", 1))

  //  val chicago = new Location(new Location.Coordinate(-86.0, 41.0), new Location.Coordinate(-87.0, 42.0))

  //////////////////////////////////////////////////////
  // Create an Endpoint to Track our terms
  class myFilterEndpoint extends TwitterSource.EndpointInitializer with Serializable {
    @Override
    def createEndpoint(): StreamingEndpoint = {
      val endpoint = new StatusesFilterEndpoint()
      endpoint.stallWarnings(false)
      endpoint.delimited(false)
      //endpoint.locations(List(chicago).asJava)
      endpoint.trackTerms(List("covid").asJava)
      endpoint
    }
  }

  val source = new TwitterSource(params.getProperties)
  val epInit = new myFilterEndpoint()

  source.setCustomEndpointInitializer(epInit)

  // get input data
  val streamSource: DataStream[String] = env.addSource(source)

  // TODO: Parameterise search term
  streamSource.addSink(new FlinkKafkaProducer[String]("covid", new SimpleStringSchema, properties))

  // execute program
  env.execute("Twitter Producer")
}
