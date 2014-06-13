#! /usr/bin/python

import json 
import csv

input = open('yelp_academic_dataset_user.json')
outfile = csv.writer(open("user.csv", "wb+"), quoting=csv.QUOTE_NONNUMERIC)
# Write CSV Header, If you dont need that, remove this line
outfile.writerow(["yelping_since", "votes_funny", "votes_useful", "votes_cool", "review_count", "name", "user_id", "friends", "fans", "average_stars", "type", "compliments", "elite"])
for line in input:
	data = json.loads(line)
	outfile.writerow([data["yelping_since"],
					  data["votes"]["funny"],
					  data["votes"]["useful"],
					  data["votes"]["cool"],
					  data["review_count"],
					  data["name"],
					  data["user_id"],
					  data["friends"],
					  data["fans"],
					  data["average_stars"],
					  data["type"],
					  data["compliments"],
					  data["elite"]])
input.close()