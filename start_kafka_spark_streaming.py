from __future__ import print_function

from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
from pyspark.sql import SQLContext

import json

from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.classification import StreamingLogisticRegressionWithSGD
from pyspark.mllib.feature import HashingTF


from pyspark.mllib.feature import Word2Vec, Word2VecModel

import sys

from os.path import expanduser



def filtering(features_l):
	new_feature_l = []

	for feature in features_l:
		if all(ord(char) < 128 for char in feature):
			if feature.rfind("#") == -1 and feature.rfind("@") == -1 and feature.rfind("https") == -1:
				feature.replace(",", "").replace(".", "").replace(":", "").replace(";", "").replace("\"", "").lower()
				new_feature_l.append(feature)

	return new_feature_l

def somma(lists, vectorSize):
	new_list = []

	for i in range(vectorSize):
		somma = 0
		for lista in lists:
			if lista is not None:
				somma += lista[i]

		new_list.append(somma)

	return new_list

def media(lists, vectorSize):
	new_list = []

	for i in range(vectorSize):
		somma = 0
		for lista in lists:
			if lista is not None:
				somma += lista[i]

		new_list.append(somma / vectorSize)

	return new_list


def check_None(list):
	
	for item in list:
		if item is not None:
			return True
	return False
	

topic_training = "training"
topic_test = "test"

bucket_name = "progettobigdataunica"


main_path = str(expanduser("~")) + "/progettobigdata"

first_n_rows = int(sys.argv[1])
vectorSize = int(sys.argv[2])
test_seconds = int(sys.argv[3])

s3a_access_key = str(sys.argv[4])
s3a_secret_key = str(sys.argv[5])
s3a_session_token = str(sys.argv[6])

#test_seconds = 30
sc = SparkContext(appName="PythonSparkStreamingKafka_RM_01")

sc._jsc.hadoopConfiguration().set("fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider")
sc._jsc.hadoopConfiguration().set("fs.s3a.access.key", s3a_access_key)
sc._jsc.hadoopConfiguration().set("fs.s3a.secret.key", s3a_secret_key)
sc._jsc.hadoopConfiguration().set("fs.s3a.session.token", s3a_session_token)

sc.setLogLevel("WARN")

config = SparkConf()
config.set("spark.streaming.stopGracefullyOnShutdown", "true") 

sqlContext = SQLContext(sc)

ssc = StreamingContext(sc, 1)



training = KafkaUtils.createStream(ssc, 'kafka_ip:2181', 'spark-streaming', {topic_training:1})
test = KafkaUtils.createStream(ssc, 'kafka_ip:2181', 'spark-streaming', {topic_test:1})


training = training.map(lambda tweet: tweet[1].replace("\"", ""))

training = training.filter(lambda tweet: "," in tweet).map(lambda tweet: tweet.split(","))




test = test.map(lambda tweet: tweet[1].replace("\"", ""))
test = test.filter(lambda tweet: "," in tweet).map(lambda tweet: tweet.split(","))


#### Word embeddings

print(first_n_rows)
print(vectorSize)

model = sqlContext.read.parquet("s3a://" + bucket_name + "/word2vec_models/500000_100/data").alias("model")

model.printSchema()


model = sc.broadcast(model.rdd.collectAsMap())



features_training = training.map(lambda tweet: (filtering(tweet[0].split(" ")), tweet[1])).map(lambda tweet: ([model.value.get(word) for word in tweet[0]], tweet[1]))
features_test = test.map(lambda tweet: (filtering(tweet[0].split(" ")), tweet[1])).map(lambda tweet: ([model.value.get(word) for word in tweet[0]], tweet[1]))


#SUM among vectors
features_training = features_training.filter(lambda tweet: check_None(tweet[0])).map(lambda tweet: (media(tweet[0], vectorSize), tweet[1]))
features_test = features_test.filter(lambda tweet: check_None(tweet[0])).map(lambda tweet: (media(tweet[0], vectorSize), tweet[1]))


features_training = features_training.map(lambda tweet: LabeledPoint(tweet[1], tweet[0])).filter(lambda labeled: labeled.features)
features_test = features_test.map(lambda tweet: LabeledPoint(tweet[1], tweet[0])).filter(lambda labeled: labeled.features)

 
model_2 = StreamingLogisticRegressionWithSGD()
model_2.setInitialWeights([0.0] * vectorSize)
model_2.trainOn(features_training)


# Test
predictions = model_2.predictOnValues(features_test.map(lambda tweet: (tweet.label, tweet.features)))

# 0 - ITA
# 1 - ENG


true_eng = predictions.window(test_seconds, 1) \
			.filter(lambda prediction: prediction[0] == 1.0 and prediction[1] == 1) \
			.map(lambda prediction: (prediction, 1)) \
			.reduceByKey(lambda a, b: a + b).pprint()

true_ita = predictions.window(test_seconds, 1) \
			.filter(lambda prediction: prediction[0] == 0.0 and prediction[1] == 0) \
			.map(lambda prediction: (prediction, 1)) \
			.reduceByKey(lambda a, b: a + b).pprint()

false_ita = predictions.window(test_seconds, 1) \
			.filter(lambda prediction: prediction[0] == 0.0 and prediction[1] == 1) \
			.map(lambda prediction: (prediction, 1)) \
			.reduceByKey(lambda a, b: a + b).pprint()

false_eng = predictions.window(test_seconds, 1) \
			.filter(lambda prediction: prediction[0] == 1.0 and prediction[1] == 0) \
			.map(lambda prediction: (prediction, 1)) \
			.reduceByKey(lambda a, b: a + b).pprint()


ssc.start()
ssc.awaitTermination()
