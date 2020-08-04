#!/bin/bash

cd ~/kafka_2.11-2.4.1

#Start zookeeper
./bin/zookeeper-server-start.sh config/zookeeper.properties & > /dev/null

#Start kafka server
./bin/kafka-server-start.sh config/server.properties & > /dev/null

#Set up topic


./bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 2 --topic test --config retention.ms=20000 & > /dev/null
./bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 2 --topic training --config retention.ms=20000 & > /dev/null


#bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
