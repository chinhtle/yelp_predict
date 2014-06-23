#! /usr/bin/python

#from multiprocessing import Process
import json
import string
import sys
import linecache
#from sets import Set

outfile1 = open('user_mapped.csv', "w")
user_data = open('user.csv', "r")
outfile2 = open('user_unmapped.csv', "w")
user_lines = user_data.readlines()
counter = 0
for line in user_lines:
	if counter == 0:
		counter += 1
		continue
	words = line.split(',')
	line_len = len(words)
	if words[line_len-1] in "0\n":
		outfile2.write(line)
	else:
		outfile1.write(line)
outfile2.close()			
user_data.close()
outfile1.close()

