from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from kafka import KafkaProducer
from json import dumps
import configparser

config = configparser.ConfigParser()
config.read('../twitter.ini')
access_token = config['DEFAULT']['access_token']
access_token_secret = config['DEFAULT']['access_token_secret']
consumer_key = config['DEFAULT']['consumer_key']
consumer_secret = config['DEFAULT']['consumer_secret']


class StdOutListener(StreamListener):
    def on_data(self, data):
        # Asynchronous by default
        #TODO: Add callbacks?
        producer.send("covid", data)
        print(data)
        return True
    def on_error(self, status):
        print(status)

# kafka = KafkaClient("localhost:9092")
producer = KafkaProducer(bootstrap_servers=['localhost:9092'],
                         value_serializer=lambda x: dumps(x).encode('utf-8'))
l = StdOutListener()
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
stream = Stream(auth, l)
#TODO: Parameterize search term
stream.filter(track=["covid"])
