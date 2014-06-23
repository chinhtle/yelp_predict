#! /usr/bin/python

#from multiprocessing import Process
import json
import string
import sys
import linecache
#from sets import Set

startcount = sys.argv[1]
outfilename = sys.argv[2]
review_file = sys.argv[3]
counter = 0
outfile = open(outfilename, "w")
user_data = open('user.csv', "r")
review_data = open(review_file)
user_lines = user_data.readline()
print user_lines
while counter <= int(startcount):
	user_lines = user_data.readline()
	counter += 1
review_lines = review_data.readline()
print "###", review_lines
uWords = user_lines.split(',')
print uWords
rWords = review_lines.split(',')
print rWords
searchWord = ""
while True:
	print "START OF FIND RWORDS", uWords, rWords
	if len(uWords) < 6:
		print "***LESSTHAN 6***\n", uWords
	elif review_lines == "":
		print "END OF FILE"
		sys.exit(0)
	searchWord = uWords[6].split('\"')
	print searchWord
	if searchWord[1] in rWords[0]:
		break
	review_lines = review_data.readline()
	rWords = review_lines.split(',')
while not review_lines == "":
	if len(uWords) < 6:
		print "***LESSTHAN 6***\n", uWords
	searchWord = uWords[6].split('\"')	
	if not searchWord[1] in rWords[0]:
		print "SOMETHING WRONG*****", uWords[6], " doesnt match ", rWords[0], "**\n"
		sys.exit(1)
	max = 0
	max_ind = 0
	outUserLine = user_lines.split("\r\n")
	outReviewLine = ","
	for ind in range(len(rWords)):
		if ind == 0:
			max = 0
			max_ind = 0
			continue
		elif '\n' in rWords[ind]:
			no_newline = rWords[ind].split('\n')
			outReviewLine = outReviewLine + no_newline[0] + ','
			if int(no_newline[0]) > int(max):
				max = no_newline[0]
				max_ind = ind
		else:	
			outReviewLine = outReviewLine + rWords[ind] + ','
			if int(rWords[ind]) > int(max):
				max = rWords[ind]
				max_ind = ind
	print searchWord[1], "\t", outReviewLine, ": ", max_ind, "\n"
	outReviewLine = outReviewLine + str(max_ind) + "\n"
	outfile.write(outUserLine[0])
	outfile.write(outReviewLine)
	user_lines = user_data.readline()
	review_lines = review_data.readline()
	rWords = review_lines.split(',')
	uWords = user_lines.split(',')
review_data.close()			
user_data.close()
outfile.close()

