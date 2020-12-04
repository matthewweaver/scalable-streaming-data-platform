package sentimentanalysis

import akka.util.Helpers.Requiring
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.{JsonNode, ObjectMapper}
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.apache.flink.api.common.typeinfo.{TypeInformation, Types}
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.ObjectNode
import org.apache.flink.streaming.api.scala.createTypeInformation

import scala.io.Source

class SentimentAnalysisUnitTest extends AnyFlatSpec with Matchers {

  "SentimentAnalysisUnitTest" should "calculate sentiment" in {

    val l = List("covid,trump")
    val resourcesPath = getClass.getResource("/sample_tweet.json")
    val json = Source.fromFile(resourcesPath.getPath).getLines.mkString
    val mapper = new ObjectMapper()
    val obj: ObjectNode = mapper.readTree(json).deepCopy()
    val tweet: Tweet = Tweet(obj).get
    val sentimentTweet = ClassifierModel("gbm_embeddings_hex").predict(tweet)
    assert(sentimentTweet == tweet.copy(score = "negative"))
  }
}

