#! /usr/bin/python

#from multiprocessing import Process
import json
import string
import sys
import linecache
#from sets import Set

PERSONALITY_MAP = ["Prosocial","Risk Taker","Anxious","Passive","Perfectionist","Critical","Conscientious","Open minded","Intuitive","Liberal"]
counter = 0
outfile = open("user_mapped_updated2.csv", "w")
user_data = open('user_mapped_updated.csv', "r")
user_lines = user_data.readlines()
for line in user_lines:
	if counter == 0:
		counter += 1
		outfile.write(line)
		continue
	print line
	words = line.split(',')
	val = words[len(words)-1].rstrip('\n')
	if "10" in val:
		words[len(words)-1] = PERSONALITY_MAP[9]+'\n'
	else:
		words[len(words)-1] = PERSONALITY_MAP[int(val)-1]+'\n'
	for i in range(len(words)):
		if i == len(words)-1:
			outfile.write(words[i])
		else:
			outfile.write(words[i])
			outfile.write(',')

	

user_data.close()
outfile.close()

