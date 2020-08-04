#!/bin/bash

./spark/sbin/start-master.sh


echo "Insert S3A_ACCESS_KEY"
read access_key
export S3A_ACCESS_KEY=$access_key

echo "Insert S3A_SECRET_KEY"
read secret_key
export S3A_SECRET_KEY=$secret_key

echo "Insert S3A_SESSION_TOKEN"
read session_token
export S3A_SESSION_TOKEN=$session_token

ssh ubuntu@kafka_ip ./progettobigdata/start_kafka.sh