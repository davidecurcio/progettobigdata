#!/bin/bash

sudo apt-get update -y > /dev/null
sudo apt-get upgrade -y > /dev/null
sudo apt-get install -y openjdk-8-jdk > /dev/null

sudo apt install -y python3-pip > /dev/null

echo "SET_IP_ADDRESS kafka_ip" | sudo tee -a /etc/hosts > /dev/null

sudo pip3 install kafka-python > /dev/null
sudo pip3 install numpy > /dev/null

wget -q https://downloads.apache.org/kafka/2.4.1/kafka_2.11-2.4.1.tgz > /dev/null

sudo tar zxf kafka_2.11-2.4.1.tgz > /dev/null

cd kafka_2.11-2.4.1/

echo "" | sudo tee -a ./config/server.properties > /dev/null
echo "advertised.listeners=PLAINTEXT://kafka_ip:9092" | sudo tee -a ./config/server.properties > /dev/null

cd ~
git clone https://github.com/davidecurcio/progettobigdata

cd ./progettobigdata
mkdir txt
cd txt/

wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1fNXaYj2yv-LcXYe2XZ1o_98yX04GkDc2' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1fNXaYj2yv-LcXYe2XZ1o_98yX04GkDc2" -O dataset.txt && rm -rf /tmp/cookies.txt
