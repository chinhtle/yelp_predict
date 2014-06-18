#! /usr/bin/python

#from multiprocessing import Process
import json
import string
import sys
#from sets import Set

#p = Pool(4)
#result = p.apply(parse_user)
#outfile = open('blah.txt' "w")
#outfile.write(result)
#print result


def isInList(word, slist):
#	print word, "\t"
#	if word > slist[len(slist)-1]:
#		return 0	#sorted review_txt optimization
	for s_word in slist:
#		print slist, word, "\t"
		if s_word in word:
			print "\n***found match:", s_word, "****", word, "\n"
			return 1
#		if s_word > word:
#			return 0
	return 0

SWEETWORDS = sorted(['CANDY', 'CHOCOLATE', 'DESSERT', 'CREAM', 'CAKE', 'SUGAR', 'CARMEL', 'SYRUP', 'HONEY', 'SHERBET', 'SORBET', 'PUDDING', 'SWEET', 'DONUT', 'GUMMIES', 'CREPE', 'MACAROON'])
SPICYWORDS = sorted([ 'CHILI', 'JALAPENO', 'CALIENTE', 'CAYENNE', 'PAPRIKA', 'SPICY', 'WASABI', 'TABASCO', 'HABANERO', 'THAI', 'CURRY', 'CUMARI', 'SERRANO', 'PEPPER', 'CHOLULA', 'SRIRACHA', 'PICANTE'])
SALTYWORDS = sorted(['RAMEN', 'PRETZEL', 'CHICKEN TENDER', 'CHIPS', 'FRENCH FRIES', 'SANDWICH', 'BURGER', 'PIZZA', 'SOUP', 'SALT', 'PEANUT', 'WALNUT', 'NUTS', 'BEAN', 'ALMOND', 'CASHEW', 'PECAN', 'PISTACHIO'])
CARBWORDS = sorted(['BAGEL', 'BREAD', 'PASTA', 'BAGUETTE', 'BISCUIT', 'ROLL', 'BUNS', 'CIABATTA', 'LOAF', 'DOUGH', 'PANCAKE', 'NAAN', 'TORTILLA', 'SPAGHETTI', 'VERMICELLI', 'LINGUINE', 'MACARONI', 'PENNE', 'RIGATONI', 'ROTINI', 'RAVIOLI', 'LASAGNA', 'NOODLE'])
CRUNCHWORDS = sorted([ 'CRUNCH', 'CRISP', 'CARROT', 'CHEWY', 'BROCCOLI', 'COOKIE', 'CHIPS', 'GRANOLA', 'CEREAL', 'APPLE', 'NUTS', 'POPCORN', 'ALMOND', 'CASHEW', 'PECAN', 'PISTACHIO'])
SOURWORDS = sorted(['ACID', 'SOUR', 'TANGY', 'VINEGAR', 'YOGURT', 'SAUERKRAUT', 'KIMCHI', 'RHUBARB', 'LEMON' 'LIME', 'KUMQUAT', 'PICKLE', 'POMELO'])
CITRUSWORDS = sorted(['CITRUS', 'ORANGE', 'LIME', 'CLEMENTINE', 'GRAPEFRUIT', 'LEMON', 'KUMQUAT', 'MANDARIN', 'POMELO', 'TANGERINE', 'TANGELO', 'TANGOR', 'POMELO', 'HEALTHY'])
EXOTICWORDS = sorted(['EXOTIC', 'SNAIL', 'FROG', 'BISON', 'ESCARGOT', 'RABBIT', 'OSTRICH', 'DEER', 'BOAR', 'ELK', 'GOAT', 'UNAGI', 'SNAKE', 'SASHIMI', 'DURIAN'])
CHOCOLATEWORDS = sorted(['CHOCOLATE', 'COCOA', 'FUDGE', 'MOCHA'])
ALCOHOLICWORDS = sorted(['ALCOHOL', 'BEER', 'LAGER', 'LIQUOR', 'SAKE', 'WINE', 'SOJU', 'WHISKY', 'BAIJIU', 'BRANDY', 'COCKTAIL', 'VODKA', 'TEQUILA'])

outfilename = sys.argv[3]
startcount = sys.argv[1]
endcount = sys.argv[2]
counter = 0
outfile = open(outfilename , "w")
user_data = open('user.csv', "rw")
review_data = open('yelp_academic_dataset_review.json')
usr_lines = user_data.readlines()
for line in usr_lines:
	words = line.split(",")
	if len(words) > 6:
		test = words[6].split("\"")
		if len(test) > 2:
			counter += 1
			review_lines = review_data.readlines()
			number_of_reviews = 0
			number_of_businesses = 0
			reviews = ""
			businessIDs = ""
			numSweet = 0
			numSpicy = 0
			numSalty = 0
			numCarb = 0
			numCrunch = 0
			numSour = 0
			numCit = 0
			numExot = 0
			numChoc = 0
			numAlc = 0
			if counter < int(startcount):
				continue
			if counter > int(endcount):
				continue
			for review_data_line in review_lines:
				data = json.loads(review_data_line)
				review_user_id = review_data_line.split("\"")
				if test[1] in data["user_id"]:
					number_of_reviews += 1
					number_of_businesses += 1
					reviews = reviews + data["text"].upper()
					businessIDs = businessIDs + data["business_id"] + ", "
					#print number_of_reviews, "\t", data["text"]
			if number_of_reviews > 0:
				review_words = reviews.split(" ")
#				sreview_words = sorted(review_words)
				for review_word in review_words: ##
					for punc in string.punctuation:
						review_word = review_word.replace(punc, "")
					if len(review_word) > 2:
						if isInList(review_word, SWEETWORDS):
							numSweet += 1
						if isInList(review_word, SPICYWORDS):
							numSpicy += 1
						if isInList(review_word, SALTYWORDS):
							numSalty += 1
						if isInList(review_word, CARBWORDS):
							numCarb += 1
						if isInList(review_word, CRUNCHWORDS):
							numCrunch += 1
						if isInList(review_word, SOURWORDS):
							numSour += 1
						if isInList(review_word, CITRUSWORDS):
							numCit += 1
						if isInList(review_word, EXOTICWORDS):
							numExot += 1
						if isInList(review_word, CHOCOLATEWORDS):
							numChoc += 1
						if isInList(review_word, ALCOHOLICWORDS):
							numAlc += 1
			print test[1], "\tnum_reviews:", number_of_reviews, " ",  numSweet, " ", numSpicy, " ", numSalty, " ", numCarb, " ", numCrunch, " ", numSour, " ", numCit, " ", numExot, " ", numChoc, " ", numAlc
			outstring = test[1] + str(number_of_reviews) + "," + str(numSweet) + "," + str(numSpicy) + "," + str(numSalty) + "," + str(numCarb) + "," + str(numCrunch)
			outstring = outstring + "," + str(numSour) + "," + str(numCit) + "," + str(numExot) + "," + str(numChoc) + "," + str(numAlc) + "\n"
			outstring = outstring.encode("utf-8")
			outfile.write(outstring)
			review_data.seek(0)
review_data.close()			
user_data.close()
outfile.close()


