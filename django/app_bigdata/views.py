from django.http import HttpResponseRedirect

from django.shortcuts import render

from .forms import NameForm

import subprocess
import os.path
import time

import shlex
from pathlib import Path

debug = True

print(str(Path.home()))
script_path = str(Path.home()) + "/progettobigdata/start_kafka_spark_streaming.sh"


def index(request):
	if request.method == "POST":
		form = NameForm(request.POST)

		#delete file if exists
		if form.is_valid():
			
			training_seconds = str(form.cleaned_data['training_seconds'])
			test_seconds = str(form.cleaned_data['test_seconds'])

			file_path = str(Path.home()) + "/progettobigdata/analysis_" + str(training_seconds) + "_" + str(test_seconds) + ".txt"

			if os.path.exists(file_path):
				os.remove(file_path)

			myCommand = [ 'python3', '/home/ubuntu/progettobigdata/kafka_python.py', "500000", training_seconds, test_seconds]

			myCommandStr = ' '.join(shlex.quote(n) for n in myCommand)
			process2 = subprocess.Popen([script_path, training_seconds, test_seconds], stdout=subprocess.PIPE)

			process = subprocess.Popen(['ssh', '-tt', '-vv', "ubuntu@kafka_ip", myCommandStr, "2>&1"], stdout=subprocess.PIPE)

			print("c")
			#DEBUG
			if debug:
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
					
			while not os.path.exists(file_path):
				time.sleep(1)

			if os.path.isfile(file_path):
				f = open(file_path, "r")
				result = f.readlines()

			else:
				raise ValueError("%s isn't a file!" % file_path)

			process.kill()
			process2.kill()
			return render(request, 'app_bigdata/index.html', {'result': result})

	else:
		form = NameForm()

	return render(request, 'app_bigdata/index.html', {'form': form})
