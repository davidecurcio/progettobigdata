from sys import stdin
import re
import sys


from pathlib import Path

main_path = str(Path.home()) + "/progettobigdata"

predictions = [[-1, -1], [-1, -1]]


training_seconds = int(sys.argv[1])
test_seconds = int(sys.argv[2])

while 1:
	pred = None
	label = None
	line = stdin.readline()
	print(line)

	if line is not None:
		pattern = re.compile(r"""\(\(
								(?P<pred>.*?),(?P<label>.*?)\),(?P<occurrencies>.*?)\)""", re.VERBOSE)

		match = pattern.match(line)

		if match is not None:
			pred = int(float(match.group("pred")))
			label = int(match.group("label"))

			occurrencies = int(match.group("occurrencies"))

			print(str(pred) + " " + str(label) + " " + str(occurrencies))

			if pred != None and label != None:
				if pred == 1 and label == 1:
					if occurrencies > predictions[pred][label]:
						predictions[pred][label] = occurrencies
					else:
						break
				else:
					predictions[pred][label] = occurrencies

tot = 0

for prediction in predictions:
	for item in prediction:
		tot += item

		print(tot)


true_pos = predictions[0][0] + predictions[1][1]

true_it = predictions[0][0]
true_en = predictions[1][1]
false_it = predictions[0][1]
false_en = predictions[1][0]


print("tot: ", str(tot))
print("true_pos: ", str(true_pos))



accuracy = true_pos / tot

print("accuracy: " + str(accuracy))

f = open(main_path + "/analysis_" + str(training_seconds) + "_" + str(test_seconds) + ".txt", "w+")

f.write("true it: " + str(true_it) + "\n")
f.write("true en: " + str(true_en) + "\n")
f.write("false it: " + str(false_it) + "\n")
f.write("false en: " + str(false_en) + "\n")


f.write("accuracy: " + str(accuracy) + "\n")
f.write("tot test: " + str(tot) + "\n")
f.write("true_pos: " + str(true_pos))
f.close()
