package sentimentanalysis

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import scala.io.Source

class IncrementMapFunctionTest extends AnyFlatSpec with Matchers {

  "IncrementMapFunction" should "increment values" in {
    // instantiate your function
    val resourcesPath = getClass.getResource("/test_tweet.json")
    val json = Source.fromFile(resourcesPath.getPath).getLines.mkString
    val tweet: Tweet = Tweet(json).get
    val output = ClassifierModel("gbm_embeddings_hex").predict(tweet)
    println("test")
  }
}

