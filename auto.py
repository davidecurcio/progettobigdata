import subprocess

import shlex

from pathlib import Path

import os.path
import sys

import time

print(str(Path.home()))
script_path = str(Path.home()) + "/progettobigdata/start_kafka_spark_streaming.sh"

training_seconds = str(sys.argv[1])
test_seconds = str(sys.argv[2])

print(training_seconds + " " + test_seconds)

file_path = str(Path.home()) + "/progettobigdata/analysis_" + str(training_seconds) + "_" + str(test_seconds) + ".txt"

myCommand = [ 'python3', '/home/ubuntu/progettobigdata/kafka_python.py', "500000", training_seconds, test_seconds]

myCommandStr = ' '.join(shlex.quote(n) for n in myCommand)

process2 = subprocess.Popen([script_path, training_seconds, test_seconds], stdout=subprocess.PIPE)

process = subprocess.Popen(['ssh', "ubuntu@kafka_ip", myCommandStr], stdout=subprocess.PIPE)

'''
while True:
            
    output = process.stdout.readline()
    if output == '' and process.poll() is not None:
        break
    if output:
        stringa = output.strip().decode('UTF-8')
        if stringa is not "":
            print(stringa)

    output2 = process2.stdout.readline()
    if output2 == '' and process2.poll() is not None:
        break
    if output2:
        stringa2 = output2.strip().decode('UTF-8')
        if stringa2 is not "":
            print(stringa2)

        if "accuracy" in stringa2:
            break
'''

while not os.path.exists(file_path):
    time.sleep(1)

print("prova")

process.terminate()
process2.terminate()


