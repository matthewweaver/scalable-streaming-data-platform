package sentimentanalysis

import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.{JsonNodeFactory, ObjectNode}
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.{JsonNode, ObjectMapper}
import org.scalatest.wordspec.AnyWordSpec
import org.scalatest.matchers.should.Matchers
import sentimentanalysis.Tweet.hashtagPattern

import scala.io.Source
import scala.reflect.io.File


class TweetSpec extends AnyWordSpec with Matchers {
  val mapper = new ObjectMapper()
  "A tweet" can {
    val obj = mapper.createObjectNode()
    "fail" in {
      assert(Tweet(obj).isFailure)
    }
    "Tweet constructor" should {

      val stream = getClass.getResourceAsStream("/sample_tweet.json")
      val messageJson = Source.fromInputStream( stream ).getLines().mkString
      val obj: ObjectNode = mapper.readTree(messageJson).deepCopy()

      val dateFormat = new SimpleDateFormat("EEE MMM dd HH:mm:ss ZZZZZ yyyy")
      val text = "I'm sad and down!"

      "parse a valid message correctly " in {

        val expectedTweet = Tweet(obj)

        val key = Set("key")
        val value = obj.get("value")
        val text: String = value.get("text").asText ()
        val time = dateFormat.parse (value.get ("created_at").asText ())
        val hashtags: Set[String] = hashtagPattern.findAllIn (text).toSet
        val words = Tokenizer().transform(text)
        val geo = value.get("user").get ("location").asText ()
        var place = "null"
        if (!value.get("place").isNull) {
          place = value.get("place").get("bounding_box").get("coordinates").get(0).get(0).toPrettyString()
        }
        var tweet_type = "normal"
        if(value.has("retweeted_status")) tweet_type ="retweet"
        if(value.has("quoted_status")) tweet_type ="reply"
        val retweet_count = value.get("retweet_count").asInt()
        val usedKey = Set("usedKey")

        val myTweet = Tweet(time, text, words, hashtags,retweet_count, geo, place, tweet_type, key, usedKey)


        assert(expectedTweet.get === myTweet)

      }
    }
  }
}