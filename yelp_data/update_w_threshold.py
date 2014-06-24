#! /usr/bin/python

#from multiprocessing import Process
import json
import string
import sys
import linecache
#from sets import Set

outfile1 = open('user_new.csv', "w")
user_data = open('user.csv', "r")
user_lines = user_data.readlines()
counter = 0
for line in user_lines:
	if counter == 0:
		counter += 1
		continue
	words = line.split("]\",")
	numVals = words[2].split(',')
	line_len = len(numVals) 
	if 11 != line_len:
		print "ERROR", numVals
		print line
		sys.exit(0)
	if numVals[line_len-1] in "0\n":
		outfile1.write(line)
	else:
		maxVal = 0
		for ind in range(len(numVals)-1):
			if int(maxVal) > 1:
				outfile1.write(line)
				break
			if int(maxVal) < int(numVals[ind]):
				maxVal = numVals[ind]
		if int(maxVal) <= 1:
			print "found change needed", line
			numVals[line_len-1] = "0\n"
			string=""
			for index in range(line_len):
				if index == line_len-1:
					string = string + str(numVals[index])
					break
				string = string + str(numVals[index]) + ','
			outLine = words[0] + "]\"," + words[1] + "]\"," + string
			outfile1.write(outLine)
			print outLine
			
user_data.close()
outfile1.close()

