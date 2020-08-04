#!/bin/bash

FIRST_N_ROWS="500000"

VECTORSIZE="100"

CLUSTER_MODE="True"

TRAINING_SECONDS=$1

TEST_SECONDS=$2

DNS=$(curl http://169.254.169.254/latest/meta-data/public-hostname)


rm ./analysis.txt 2> /dev/null

~/spark/bin/spark-submit --master spark://$DNS:7077 --jars ~/spark-streaming-kafka-0-8-assembly_2.11-2.4.5.jar ~/progettobigdata/start_kafka_spark_streaming.py $FIRST_N_ROWS $VECTORSIZE $TEST_SECONDS $S3A_ACCESS_KEY $S3A_SECRET_KEY $S3A_SESSION_TOKEN 2> /dev/null | python3 ~/progettobigdata/handle_output.py $TRAINING_SECONDS $TEST_SECONDS
