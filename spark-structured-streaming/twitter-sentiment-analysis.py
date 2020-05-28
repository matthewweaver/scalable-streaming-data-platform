from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import json
import sys

from pyspark.sql.types import *
import os
os.environ['PYSPARK_SUBMIT_ARGS'] = "--packages=org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 pyspark-shell"

def sentiment_analyzer_scores(sentence):
    score = analyser.polarity_scores(sentence)
    # return score
    print(score)
    #print("{:-<40} {}".format(sentence, str(score)))


if __name__ == "__main__":
    analyser = SentimentIntensityAnalyzer()

    vader_udf = udf(lambda data: sentiment_analyzer_scores(data), StringType())

    schema_input = StructType([StructField('data', StringType())])
    schema_output = StructType([StructField('neg', StringType()), \
                                StructField('pos', StringType()), \
                                StructField('neu', StringType()), \
                                StructField('compound', StringType())])

    spark = SparkSession \
        .builder \
        .appName("TwitterSentimentAnalysis") \
        .getOrCreate()

    df_raw = spark \
        .readStream \
        .format('kafka') \
        .option('kafka.bootstrap.servers', ' localhost:9092') \
        .option("startingOffsets", "earliest") \
        .option('subscribe', 'covid') \
        .load()

    df_json = df_raw.selectExpr('CAST(value AS STRING) as json')

    #TODO: Why do tweets appear 4 times?
    #TODO: Format tweet better

    df_json.select(from_json(vader_udf(df_json.json), schema_output).alias('response'))\
        .select('response.*') \
        .writeStream \
        .format("console") \
        .start() \
        .awaitTermination()

    # .trigger(once=True) \
    # .select('response.*', 'sentence.data') \
    #     df_json.select(from_json(df_json.json, schema_input).alias('sentence'),\