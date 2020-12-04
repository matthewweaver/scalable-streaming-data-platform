package sentimentanalysis

import java.text.SimpleDateFormat
import java.util.Date

//import net.liftweb.json.DefaultFormats
//import net.liftweb.json.Serialization.write
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.{JsonNode, ObjectMapper}
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.ObjectNode

import scala.util.Try


case class Tweet(time: Date, text: String, words: Seq[String], hashtags: Set[String],retweet_count: Int=0, geo: String = "unknown", tweet_type: String = "normal", key:Set[String] = Set(), usedKey:Set[String] = Set(), score: String = "undefined")
// TODO: Should this write be added in
//{
//  override def toString: String = {
//    implicit val formats = DefaultFormats
//    write(this)
//  }
//}

object Tweet {
  val hashtagPattern = """(\s|\A)#(\w+)""".r
  val wordPattern = """\w+""".r
  val dateFormat = new SimpleDateFormat("EEE MMM dd HH:mm:ss ZZZZZ yyyy")

  def apply(obj: ObjectNode): Try[Tweet] ={
    Try({
      // TODO: Add search term to key
//      val key = obj.get("key").asText().split(" ").toSet
      val key = Set("key")
      val value = obj.get("value")
      var text = ""
//      var text = obj.get("text").asText ()
      if (value.get("truncated").asBoolean()){
        text = value.get("extended_tweet").get("full_text").asText ()
      }
      else{
        text = value.get("text").asText ()
      }
      val time = dateFormat.parse (value.get ("created_at").asText ())
//      val time = dateFormat.parse ("Thu Nov 26 16:05:10 +0000 2020")
      val hashtags: Set[String] = hashtagPattern.findAllIn (text).toSet
      val words = Tokenizer().transform(text)
      val geo = value.get("user").get("location").asText ()
      var tweet_type = "normal"
      if(value.get("retweeted").asBoolean()) tweet_type ="retweet"
      if(value.get("is_quote_status").asBoolean()) tweet_type ="reply"
      val retweet_count = value.get("retweet_count").asInt()
//      val usedKey = key.filter(words.contains(_))
      val usedKey = Set("usedKey")

      Tweet(time, text, words, hashtags,retweet_count, geo, tweet_type, key, usedKey)
    })
  }
}

