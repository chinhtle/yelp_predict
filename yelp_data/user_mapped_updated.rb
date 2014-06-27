require 'csv'

#function to convert string to array 
def convert_to_array(attr)
  if attr == '[]'
    attr = ''
  end
  attr = attr.split(',')
  return attr
end

new_user_mapped = []

csv_file = CSV.foreach('user_mapped.csv', :headers => true) do |row|
  #num of friends
  row['friends'] = convert_to_array(row['friends']).length.to_s
  #num of elite
  row['elite'] = convert_to_array(row['elite']).length.to_s
  #num of compliments
  row['compliments'] = convert_to_array(row['compliments'])
  sum = 0
  for elem in row['compliments']
    elem = elem.tr("{}':/[a-z]/", '')
    if elem == ''
      elem = '0'
    end
    elem = elem.strip
    elem = elem.to_i
    sum = sum + elem 
  end
  row['compliments'] = sum 
  #putting each row in new array
  new_user_mapped << row
end

#creating a csv file with the new array
CSV.open('user_mapped_updated.csv', 'w') do |csv_object|
  csv_object << ["yelping_since","votes_funny","votes_useful","votes_cool","review_count","name","user_id","friends","fans","average_stars","type","compliments","elite","num_sweet","num_spicy","num_salty","num_carbs","num_crunchy","num_sour","num_citrus","num_exotic","num_chocolate ","num_alcoholic","personality"]
  new_user_mapped.each do |row_array|
    csv_object.puts row_array
  end
end
