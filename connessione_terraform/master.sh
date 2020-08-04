#!/bin/bash

CHIAVE="key_bigdata.pem"
DNS=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

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

# SSH setup

touch /home/ubuntu/.ssh/config

echo Host kafka_ip >> /home/ubuntu/.ssh/config
echo HostName kafka_ip >> /home/ubuntu/.ssh/config
echo User ubuntu >> /home/ubuntu/.ssh/config
echo IdentityFile /home/ubuntu/.ssh/$CHIAVE >> /home/ubuntu/.ssh/config

echo "SSH has been set up"

#Modifying /etc/hosts
echo | sudo tee -a /etc/hosts > /dev/null
echo "SET_IP_ADDRESS kafka_ip" | sudo tee -a /etc/hosts > /dev/null


ssh-keygen -qq -f /home/ubuntu/.ssh/id_rsa -t rsa -P ''
cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys

echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee -a $HADOOP_CONF_DI/hadoop-env.sh > /dev/null

sudo chown -R ubuntu $HADOOP_HOME

# Spark setup
wget -q https://downloads.apache.org/spark/spark-2.4.6/spark-2.4.6-bin-without-hadoop.tgz > /dev/null
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

cd ~
wget -q https://downloads.apache.org/kafka/2.4.1/kafka_2.11-2.4.1.tgz > /dev/null
tar -xf kafka_2.11-2.4.1.tgz > /dev/null

#Pip install
sudo apt install -y python3-pip

sudo pip3 install pyspark==2.4.6
sudo pip3 install kafka-python
sudo pip3 install numpy

wget -q https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-8-assembly_2.11/2.4.5/spark-streaming-kafka-0-8-assembly_2.11-2.4.5.jar

python3 -m pip install Django

cd ~
git clone https://github.com/davidecurcio/progettobigdata

cd ./progettobigdata
mkdir txt
cd txt/
