from time import sleep, time
from json import dumps
from kafka import KafkaProducer

import sys

from pathlib import Path


print(sys.argv)
first_n_rows = int(sys.argv[1])

seconds_training = int(sys.argv[2])
seconds_test = int(sys.argv[3])

bootstrap_servers = ["localhost:9092"]
main_path =str(Path.home()) + "/progettobigdata"
analysis_path = str(Path.home()) + "/progettobigdata/analysis.txt"
path = main_path + "/txt/dataset.txt"

n_training = 8
n_test = 3

topic_training = "training"
topic_test = "test"

rows_per_second = 153662

producer = KafkaProducer(bootstrap_servers=bootstrap_servers, value_serializer=lambda x: dumps(x).encode("utf-8"))
#Lettura file

file = open(path, "r", errors='replace')

sleep(60)

#Training

for _ in range(first_n_rows):
	stringa = file.readline().rstrip()

delta_time = 0

start_time = time()
c = 0
while(delta_time < seconds_training):

	producer.send(topic_training, file.readline().rstrip())
	end_time = time()
	delta_time = end_time - start_time

	c += 1

	if c % 10000 == 0:
		print(c)

print("Total training: " + str(c))

sleep(60)


#Test
print("Test")


delta_time = 0

start_time = time()
c = 0
while(delta_time < seconds_test):

	producer.send(topic_test, file.readline().rstrip())

	end_time = time()
	delta_time = end_time - start_time

	c += 1
	if c % 10000 == 0:
		print(c)


print("total records: " + str(c))


producer.flush()
file.close()
