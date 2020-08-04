#!/bin/bash

CHIAVE="key_bigdata.pem"
MASTER_DNS=$1

sudo apt-get update -y > /dev/null
sudo apt-get upgrade -y > /dev/null
sudo apt-get install -y openjdk-8-jdk > /dev/null

echo "openjdk-8-jdk has been installed"

# Download and extract Hadoop
wget -q https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz > /dev/null
sudo tar zxvf hadoop-3.1.2.tar.gz > /dev/null
mkdir hadoop
sudo mv ./hadoop-3.1.2/* /home/ubuntu/hadoop
rm hadoop-3.1.2.tar.gz

echo "Hadoop has been extracted"

# Modifying environment variables

echo >> /home/ubuntu/.profile

echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 >> /home/ubuntu/.profile
echo export PATH='$PATH':'$JAVA_HOME'/bin >> /home/ubuntu/.profile
echo export HADOOP_HOME=/home/ubuntu/hadoop >> /home/ubuntu/.profile
echo export PATH='$PATH':/home/ubuntu/hadoop/bin >> /home/ubuntu/.profile
echo export PATH='$PATH':/home/ubuntu/hadoop/sbin >> /home/ubuntu/.profile
echo export HADOOP_CONF_DI=/home/ubuntu/hadoop/etc/hadoop >> /home/ubuntu/.profile

source /home/ubuntu/.profile

echo "Hadoop has been installed"


#Modifying /etc/hosts
echo | sudo tee -a /etc/hosts > /dev/null
echo "SET_IP_ADDRESS kafka_ip" | sudo tee -a /etc/hosts > /dev/null



echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee -a $HADOOP_CONF_DI/hadoop-env.sh > /dev/null

sudo chown -R ubuntu $HADOOP_HOME

# Spark setup
wget -q https://downloads.apache.org/spark/spark-2.4.6/spark-2.4.6-bin-without-hadoop.tgz
tar xzf spark-2.4.6-bin-without-hadoop.tgz > /dev/null
sudo mv ./spark-2.4.6-bin-without-hadoop /home/ubuntu/spark
rm spark-2.4.6-bin-without-hadoop.tgz
sudo cp spark/conf/spark-env.sh.template spark/conf/spark-env.sh

echo export SPARK_MASTER_HOST=\"$DNS\" | sudo tee -a spark/conf/spark-env.sh > /dev/null
echo export HADOOP_CONF_DIR=\"/home/ubuntu/hadoop/etc/hadoop\" | sudo tee -a spark/conf/spark-env.sh > /dev/null
echo export PYSPARK_PYTHON=python3 | sudo tee -a spark/conf/spark-env.sh > /dev/null

echo export SPARK_DIST_CLASSPATH=$(hadoop classpath) | sudo tee -a spark/conf/spark-env.sh > /dev/null
echo export SPARK_HOME=~/spark | sudo tee -a spark/conf/spark-env.sh > /dev/null
echo export PATH=$SPARK_HOME/bin:$PATH | sudo tee -a spark/conf/spark-env.sh > /dev/null

cd ~/spark/jars
wget -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.1.2/hadoop-aws-3.1.2.jar
wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.271/aws-java-sdk-bundle-1.11.271.jar

sudo apt install -y python3-pip
sudo pip3 install numpy

cd ~
git clone https://github.com/davidecurcio/progettobigdata

cd ./progettobigdata
mkdir txt
cd txt/

