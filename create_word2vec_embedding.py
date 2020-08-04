from pyspark import SparkContext
from pyspark.sql import SQLContext


from pyspark.mllib.feature import Word2Vec, Word2VecModel

from pyspark.sql.types import StructType
from pyspark.sql.types import StructField
from pyspark.sql.types import StringType

import sys

schema = StructType([StructField("text", StringType(), True)])



def filtering(features_l):
	new_feature_l = []

	for feature in features_l:
		if all(ord(char) < 128 for char in feature):
			if feature.rfind("#") == -1 and feature.rfind("@") == -1 and feature.rfind("https"):
				feature.replace(",", "").replace(".", "").replace(":", "").replace(";", "").replace("\"", "").lower()
				new_feature_l.append(feature)

	return new_feature_l

first_n_rows = int(sys.argv[1])

vectorSize = int(sys.argv[2])

sc = SparkContext(appName = "Prova")

sqlContext = SQLContext(sc)
test = sc.textFile("txt/dataset_" + str(first_n_rows) + ".txt")

#test = test.map(lambda tweet: tweet[1].replace("\"", ""))
test = test.filter(lambda tweet: "," in tweet).map(lambda tweet: tweet.split(","))

test = test.map(lambda tweet: filtering(tweet[0].split(" ")))


word2vec = Word2Vec().setVectorSize(vectorSize)

model = word2vec.fit(test)

print(model.getVectors())

model.save(sc, "word2vec_models/" + str(first_n_rows) + "_" + str(vectorSize))
