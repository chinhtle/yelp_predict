require 'rubygems/package'
require 'zlib'
require 'json'
require 'csv'
require 'personality'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'common'
require 'rjb'

module BusinessesHelper
  include UsersHelper

  CURR_DIR = File.dirname(__FILE__)
  DATA_PATH = File.join(CURR_DIR, '../../yelp_data')
  BUSINESS_DATA_PATH = "#{DATA_PATH}/business_data"
  BUSINESS_REVIEWS_PATH = "#{BUSINESS_DATA_PATH}/business_reviews"

  # Business Reviews Data Set Constants
  DATASET_PREFIX = 'yelp_business_data_set'
  COMPRESSED_EXT = 'tar.gz'
  EXTRACTED_DATA_EXT = 'json'
  EXTRACTED_DATA_FILE_OPTIONS = 'a+' # Reading and appending. Create if needed
  EXTRACTED_FILENAME = "#{DATASET_PREFIX}.#{EXTRACTED_DATA_EXT}"
  EXTRACTED_FILEPATH = "#{BUSINESS_REVIEWS_PATH}/#{EXTRACTED_FILENAME}"

  # Hash Key Constants
  HASH_KEY_BUSINESS_ID = 'business_id'
  HASH_KEY_USER_ID = 'user_id'
  HASH_KEY_REVIEW_TEXT = 'text'

  # User Data Set Constants
  USER_DATA_FILENAME = 'user_remapped_intro_extro.csv'
  USER_DATA_FILEPATH = "#{DATA_PATH}/#{USER_DATA_FILENAME}"
  USER_ID_CSV_NAME = HASH_KEY_USER_ID
  USER_PERSONALITY_CSV_NAME = 'personality'

  # Personality Summary Constants. P = Personality.
  P_HIGHEST_TYPE_KEY = 'dominant_type'
  P_HIGHEST_VALUE_KEY = 'dominant_value'

  # Used to decide when feedback prints should be printed
  FEEDBACK_PRINT_THRESH = 10000

  # Business Info Constants:
  # This array is used to contain the keys
  # that we're interested in from the data set.  This should be a subset of
  # the business model.
  BUSINESS_INFO_KEYS = {name_key: 'name', stars_key: 'stars',
                        review_count_key: 'review_count', city_key: 'city',
                        state_key: 'state', address_key: 'full_address'}
  BUSINESS_INFO_PATH = "#{BUSINESS_DATA_PATH}/business_info"
  BUSINESS_INFO_FILENAME = 'yelp_academic_dataset_business.json'
  BUSINESS_INFO_FILEPATH = "#{BUSINESS_INFO_PATH}/#{BUSINESS_INFO_FILENAME}"

  # Heroku Constants:
  # Heroku DB limit is 10k for free, basic, service.  We will use 9500.
  # Since only storing businesses, it would not affect our application.
  # Set at 9500 in case we want to add other dynamic business crawlers.
  HEROKU_DB_RECORD_LIMIT = 9500

  # Some table configurations
  RESULTS_TABLE_CONFIGS = '' # No particular configs for now..
  RESULTS_TABLE_CLASSES = 'table table-hover'

  # Constants for the remapping helper function
  REMAP_DATA_FILENAME = 'user_remapped_intro_extro.csv'
  REMAP_FILEPATH = "#{DATA_PATH}/#{REMAP_DATA_FILENAME}"

  # Flag for enabling adding review text to the remapping function.
  ADD_REVIEW_TEXTS = false

  # Time to wait between each request to avoid being identified as crawler
  GET_REQ_TIME = 0.25 # quarter of a second

  def load_bus_data
    puts 'Loading business data..'

    begin
      # Extract data sets first, and proceed only if successful
      if extract_data_sets
        puts 'Extract successful. Proceeding to load from extracted JSON file'
        business_customers_hash = {}
        business_info_hash = {}
        customer_personality_hash = {}

        # Load the business reviews JSON
        load_bus_reviews_to_hash(business_customers_hash,
                                 EXTRACTED_FILEPATH,
                                 HASH_KEY_BUSINESS_ID,
                                 HASH_KEY_USER_ID)

        # Load the business information JSON
        load_bus_info_to_hash(business_info_hash,
                              BUSINESS_INFO_FILEPATH,
                              BUSINESS_INFO_KEYS)

        # Now that we know which users are associated with the businesses,
        # read in from the users data set file to obtain their associated
        # personalities.
        load_csv_to_hash(customer_personality_hash,
                         REMAP_FILEPATH)

        # Associate the business and customer personality hashes.  Store
        # the personality into the business customer hash
        retrieve_user_personality(business_customers_hash,
                                  customer_personality_hash)

        # Now that the data is associated, we can pass the hash of users
        # with their personality to the method to obtain a summary of the types
        # of personalities for the business.
        summarize_and_add_business_to_db(business_customers_hash,
                                         business_info_hash)
      end

      puts 'Loaded all data successfully.'
    rescue
      $stderr.print 'Error while processing: ' + $!
    ensure
      # Remember to delete the extracted data set
      delete_extracted_data
    end
  end

  def summarize_and_add_business_to_db(business_hash, business_info_hash)
    puts 'Summarizing and adding business to DB..'

    # Go through each business and get the summary of the personality types
    # and add it to the business database.
    business_hash.each do |business_id, user_hash|
      # Only proceed if we have associated business information in our hash.
      business_info = business_info_hash[business_id]

      if business_info.nil?
        puts "Skipping. No business info for business-id: #{business_id}."
      else
        # Create a temporary hash used for the output of the summary
        tmp_hash = Hash.new(0)

        get_personality_summary_hash(user_hash, tmp_hash)

        puts "Summary for business-#{business_id}:"

        # Print the summary for this business.
        tmp_hash.each do |personality, value|
          puts "\t#{personality}: #{value}"
        end

        add_business_to_model_by_hash(business_id, tmp_hash, business_info)
      end
    end
  end

  def add_business_to_model_by_hash(business_id, summary_hash,
                                    business_info_hash)
    # Add the new entry to the table
    if Business.count < HEROKU_DB_RECORD_LIMIT
      Business.create(
        business_id:       business_id,
        name:              business_info_hash[BUSINESS_INFO_KEYS[:name_key]],
        stars:             business_info_hash[BUSINESS_INFO_KEYS[:stars_key]],
        review_count:      business_info_hash[BUSINESS_INFO_KEYS[:review_count_key]],
        city:              business_info_hash[BUSINESS_INFO_KEYS[:city_key]],
        state:             business_info_hash[BUSINESS_INFO_KEYS[:state_key]],
        full_address:      business_info_hash[BUSINESS_INFO_KEYS[:address_key]],
        dominant_type:     summary_hash[P_HIGHEST_TYPE_KEY],
        dominant_value:    summary_hash[P_HIGHEST_VALUE_KEY],
        num_introverted:   summary_hash[Personality::INTRO_EXTRO_KEYS[Personality::INTROVERTED]],
        num_extroverted:   summary_hash[Personality::INTRO_EXTRO_KEYS[Personality::EXTROVERTED]])
    end
  end

  def load_bus_info_to_hash(business_info_hash, filepath, business_info_keys)
    puts 'Loading Business Info JSON to hash.'

    # Check if the file exists
    if File.file?(filepath)
      print_idx = 0

      File.open(filepath, 'r').each do |line|
        # Parse JSON
        data_hash = JSON.parse(line)

        # Each business is represented by a business_id.
        business_id = data_hash[HASH_KEY_BUSINESS_ID]

        # For each line, go through the array to retrieve the associated values.
        business_info_keys.each_value do |info_key|
          value = data_hash[info_key]

          puts "Business: #{business_id}"
          puts "Key: #{info_key}, Value: #{value}"

          # Print feedback every N records processed
          if print_idx % FEEDBACK_PRINT_THRESH == 0
            print '.'
          end

          # For this business, add the info.  If nil, create new hash first.
          if business_info_hash[business_id].nil?
            business_info_hash[business_id] = Hash.new
          end

          business_info_hash[business_id][info_key] = value

          print_idx += 1
        end
      end

      puts '' # Newline after the feedback prints.
    else
      puts 'Could not open file'
    end
  end

  def retrieve_user_personality(business_hash, customer_personality_hash)
    puts 'Retrieving user personalities...'

    # Now iterate through each business and get the associated personality
    # for each user.
    business_hash.each_value do |users_hash|
      # Each value of the business hash is a hash of associated users of the
      # business.  Need to iterate through each of the associated users
      # and do a hash lookup for the user's personality.
      users_hash.each_key do |user|
        # Lookup using the customer personality hash previously loaded.
        # Since this is from the data set, we will assume the user is always
        # present to avoid additional checking to reduce runtime.
        personality = customer_personality_hash[user]

        # Store the personality from the business' users hash
        if personality.nil?
          puts "User-id: #{user} was not found in customer-to-personality hash."
        else
          puts "Adding personality type: #{personality}"
          users_hash[user] = personality
        end
      end
    end
  end

  def get_all_user_personality_counts
    puts 'Printing all users personality counts:'

    customer_personality_hash = {}

    # First load the CSV file
    load_csv_to_hash(customer_personality_hash,
                     USER_DATA_FILEPATH)

    personality_count_hash = {}

    # Now iterate through each customer and store the personality types.
    customer_personality_hash.each_value do |personality|
      if personality_count_hash.has_key? personality
        personality_count_hash[personality] += 1
      else
        personality_count_hash[personality] = 1
      end
    end

    # Print the count for each personality type now.
    personality_count_hash.each do |personality, count|
      puts "Type: #{personality}, Count: #{count}"
    end
  end

  def load_csv_to_hash(hash, filepath)
    puts "Loading CSV (#{filepath}) to hash"

    # Check if the file exists
    if File.file?(filepath)
      print_idx = 0

      CSV.foreach(filepath, headers:true) do |row|
        key = row[USER_ID_CSV_NAME]
        value = row[USER_PERSONALITY_CSV_NAME]

        #puts "Key: #{key}, Value: #{value}"

        # Print feedback every N records processed
        if print_idx % FEEDBACK_PRINT_THRESH == 0
          print '.'
        end

        # Store into hash the key-value pair
        hash[key] = value

        print_idx += 1
      end

      puts '' # Newline after the feedback prints.
    else
      puts "User CSV file does not exist!"
    end
  end

  def remap_personalities_from_csv
    puts 'Remapping personalities from CSV..'

    if ADD_REVIEW_TEXTS
      user_review_hash = {}
      get_user_review_texts_hash(user_review_hash)
    end

    # Check if the file exists
    if File.file?(USER_DATA_FILEPATH)
      # Open output file
      CSV.open(REMAP_FILEPATH, 'w', force_quotes:true) do |csv_out|
        # Get headers
        headers = CSV.read(USER_DATA_FILEPATH).first

        # Print headers out first.
        csv_out << headers

        CSV.foreach(USER_DATA_FILEPATH, headers:true) do |row|
          # Retrieve the associated personality
          mapped_type = Personality::PERSONALITY_INTRO_EXTRA_MAP[
                          row[USER_PERSONALITY_CSV_NAME]]

          puts "Type: #{row[USER_PERSONALITY_CSV_NAME]}, Mapped: #{mapped_type}"

          # Update the mapped personality
          row[USER_PERSONALITY_CSV_NAME] = mapped_type

          if ADD_REVIEW_TEXTS
            # Add the user's review texts
            row[HASH_KEY_REVIEW_TEXT] =
              "#{user_review_hash[row[HASH_KEY_USER_ID]].gsub!(/[,'\r\n"]/,'')}"
          end

          # output the record
          if (ADD_REVIEW_TEXTS && !row[HASH_KEY_REVIEW_TEXT].blank?) ||
             !ADD_REVIEW_TEXTS
              csv_out << row.fields
          end
        end
      end
    else
      puts "User CSV file does not exist!"
    end
  end

  def load_bus_reviews_to_hash(hash, filepath, primary_key, secondary_key)
    puts "Loading Business Reviews JSON to hash. Primary: #{primary_key}, " \
         "Secondary: #{secondary_key}"

    # Check if the file exists
    if File.file?(filepath)
      print_idx = 0

      File.open(filepath, 'r').each do |line|
        # Parse JSON
        data_hash = JSON.parse(line)

        key = data_hash[primary_key]
        value = data_hash[secondary_key]

        # puts "Line: #{line}"
        # puts "Key: #{key}, Value: #{value}"

        # Print feedback every N records processed
        if print_idx % FEEDBACK_PRINT_THRESH == 0
          print '.'
        end

        # Now store the value into the hash.  If this is a new
        # key, then create a hash and add the value
        if hash.has_key?(key)
          hash[key][value] = nil # Just make sure value is added as key to hash
        else
          hash[key] = Hash.new
          hash[key][value] = nil
        end

        print_idx += 1
      end

      puts '' # Newline after the feedback prints.
    else
      puts 'Could not open file'
    end
  end

  def load_user_reviews_to_hash(hash, filepath, primary_key, secondary_key)
    puts "Loading User Reviews JSON to hash. Primary: #{primary_key}, " \
         "Secondary: #{secondary_key}"

    # Check if the file exists
    if File.file?(filepath)
      print_idx = 0

      File.open(filepath, 'r').each do |line|
        # Parse JSON
        data_hash = JSON.parse(line)

        key = data_hash[primary_key]
        value = data_hash[secondary_key]

        # puts "Line: #{line}"
        # puts "Key: #{key}, Value: #{value}"

        # Print feedback every N records processed
        if print_idx % FEEDBACK_PRINT_THRESH == 0
          print '.'
        end

        # Append the text
        if hash.has_key?(key)
          hash[key] += value
        else
          hash[key] = ''
        end

        print_idx += 1
      end

      puts '' # Newline after the feedback prints.
    else
      puts 'Could not open file'
    end

    delete_extracted_data
  end

  # Requires a hash of users and their personalities.
  def get_personality_summary_hash(users_personality_hash, out_hash)
    # Each personality will be recorded as
    # tallies only.  Don't need to retrieve as percentage.
    users_personality_hash.each do |user, personality|
      # Only add if they have a valid personality associated
      if personality.nil?
        puts "User: #{user} doesn't have a valid personality. Skipping."
      else
        puts "User: #{user}, Personality: #{personality}"

        out_hash[personality] += 1

        # Record the highest value and type
        if out_hash[personality] > out_hash[P_HIGHEST_VALUE_KEY]
          puts "Highest personality type: #{personality}, "\
               "value: #{out_hash[personality]}"

          # Update the new highest personality type/value
          out_hash[P_HIGHEST_TYPE_KEY] = personality
          out_hash[P_HIGHEST_VALUE_KEY] = out_hash[personality]
        end
      end
    end
  end

  def extract_data_sets
    # Clean existing extracted file if it currently exists
    delete_extracted_data

    puts "Extracting business review data from path: #{BUSINESS_REVIEWS_PATH}"

    # Since there are more than one data set, identify how many files are in
    # the business data path.
    num_files = Dir.glob(File.join(BUSINESS_REVIEWS_PATH, '**', '*')).select {
                  |file| File.file?(file)
                }.count

    if num_files > 0
      index = 1 # Files start at 1 base

      # Create the single JSON file to write to
      extracted_file = File.open(EXTRACTED_FILEPATH,
                                 EXTRACTED_DATA_FILE_OPTIONS)

      while index <= num_files do
        # Iterate through each tar
        file_path = "#{BUSINESS_REVIEWS_PATH}/" \
                    "#{DATASET_PREFIX}_#{index}.#{COMPRESSED_EXT}"

        tar_extract = Gem::Package::TarReader.new(
                          Zlib::GzipReader.open(file_path))
        tar_extract.rewind # The extract has to be rewound after each iteration
        tar_extract.each do |entry|
          puts entry.full_name
          puts entry.directory?
          puts entry.file?

          extracted_file.write(entry.read)
        end
        tar_extract.close

        index += 1
      end

      extracted_file.close
      success = true
    else
      puts 'No files to extract.'
      success = false
    end
  end

  def delete_extracted_data
    puts 'Deleting extracted data..'
    if File.file?(EXTRACTED_FILEPATH)
      File.delete(EXTRACTED_FILEPATH)
    end
  end

  def add_personalities_to_data_table(table, business)
    table.new_column('string', 'Personality')
    table.new_column('number', 'Matches')

    table.add_rows(3)
    table.set_cell(Personality::INTROVERTED, 0,
                   Personality::INTRO_EXTRO_KEYS[Personality::INTROVERTED])
    table.set_cell(Personality::INTROVERTED, 1, business.num_introverted)
    table.set_cell(Personality::EXTROVERTED, 0,
                   Personality::INTRO_EXTRO_KEYS[Personality::EXTROVERTED])
    table.set_cell(Personality::EXTROVERTED, 1, business.num_extroverted)
  end

  def print_businesses_search_results(results, business_name)
    puts "Adding businesses search results for #{business_name}"

    if results
      res = ""

      elem_idx = 0
      elems_per_row = 2
      results.each do |business|
        if (elem_idx % elems_per_row) == 0
          res << '<row>'
        end

        res << draw_business_summary_card(business)

        if (elem_idx % elems_per_row) != 0
          res << '</row>'
        end

        elem_idx = elem_idx + 1
      end
    else
      res = "<h2>No results for <i><b>#{business_name}</b></i></h2>"
    end

    return res.html_safe
  end

  def get_user_review_texts_hash(user_review_hash)
    puts 'Getting user review texts hash...'
    if extract_data_sets
      puts 'Extract successful. Proceeding to load from extracted JSON file'

      # Load the business reviews JSON
      load_user_reviews_to_hash(user_review_hash,
                                EXTRACTED_FILEPATH,
                                HASH_KEY_USER_ID,
                                HASH_KEY_REVIEW_TEXT)
    end
  end

  def render_google_visualr_chart(business_hash)
    #https://developers.google.com/chart/interactive/docs/gallery/piechart?csw=1

    data_table = GoogleVisualr::DataTable.new

    # Go through all the personalities and identify if it exists. If it does
    # then it is added to the pie chart.
    add_personalities_to_data_table(data_table, business_hash)

    # Assigning more colors than the actual number of elements is OK,
    # but if there are more elements than colors then the scheme will be
    # off! Make sure there are enough pastel colors! We will assume
    # there will not be more elements, ever, than the actual number
    # of pastel colors.
    slice_pastel_colors = [{color: '#DEA5A4'}, {color: '#77DD77'},
                           {color: '#AEC6CF'}, {color: '#B39EB5'},
                           {color: '#CB99C9'}, {color: '#779ECB'},
                           {color: '#836953'}, {color: '#FF6961'},
                           {color: '#B39EB5'}, {color: '#FDFD96'}]

    opts   = { :height => 400,
               :pieHole => 0.5, :legend => {position: 'bottom', maxLines: 3},
               :slices => slice_pastel_colors}

    @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)
  end

  def render_high_charts(business_hash)
    data_array = []
    @all_personalities = 0

    # Get total personality count, which will be used for percentage.
    Personality::INTRO_EXTRO_KEYS.each_key do |key|
      @all_personalities += business_hash[Personality::INTRO_EXTRO_NUM_KEYS[key]]
    end

    # Create the data array from the different types of personalities.
    Personality::INTRO_EXTRO_KEYS.each do |key, p_type|
      curr_type_val = business_hash[Personality::INTRO_EXTRO_NUM_KEYS[key]]

      # Only add it to the data array if it has a non-zero value
      if curr_type_val > 0
        # At each point, check if it is the highest recorded personality type.
        # If it is, then it will be the default selected slice.
        if p_type == business_hash[P_HIGHEST_TYPE_KEY]
          # Since it is the highest, we will make it default selected. This
          # requires making a new hash
          slice_data = {name: p_type, y: curr_type_val,
                        sliced: true, selected: true}
        else
          slice_data = [p_type, curr_type_val]
        end

        # Add it to the data array
        data_array.push(slice_data)
      end
    end

    @chart = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [0, 0, 50, 0]} )
      series = {
        :type=> 'pie',
        :name=> 'Personality Summary',
        :data=> data_array
      }
      f.series(series)
      # f.options[:title][:text] = "Personality Summary"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',
                                              :right=> '50px',:top=> '100px'})
      f.plot_options(:pie=>{:allowPointSelect=>true,
                            :cursor=>"pointer" ,
                            :dataLabels=>{:enabled=>true,
                                          :color=>"black",
                                          :style=>{:font=>"13px Trebuchet MS, "\
                                                          "Verdana, "\
                                                          "sans-serif"}}})
    end
  end

  def show_personality_description personality_type
    res = '<h2>'
    res << '<b>'
    res << "#{Personality::INTRO_EXTRO_TO_BUSINESS_TERM[personality_type]} "
    res << '</b>'
    res << '<i>'
    res << '<br>'
    res << Personality::INTRO_EXTRO_PRONOUNCE[personality_type]
    res << '</i>'
    res << '<br><br>'
    res << Personality::INTRO_EXTRO_DESCRIPTION[personality_type]
    res << '</h2>'
    return res.html_safe
  end

  def show_address address
    addr_array = address.split("\n")

    res = '<h2>'
    res << addr_array[0]
    res << '<br>'
    res << addr_array[1]
    res << '</h2>'

    return res.html_safe
  end

  def is_business_url query_str
    return query_str.include? '/biz/'
  end

  def retrieve_business_info_from_url business_url, update_if_found
    page = Nokogiri::HTML(open(business_url, Common::CRAWL_USER_AGENT))

    # First obtain the business-id and check if we already have it in our
    # database, if so, we can proceed to redirect the user to the results page.
    # But only redirect if update_if_found flag is false, otherwise, we will
    # still need to parse the page to get all data to update record in DB, if it
    # exists.
    # if update_if_found
    retrieved_bus_id =
      page.css('div.mapbox-text a')[0]['href'].split("biz_id=")[1]

    if !retrieved_bus_id.blank?
      # Perform a lookup using the retrieved business-id
      business = Business.find_by(business_id: retrieved_bus_id)
      business_hash = {}
      user_urls = {}
      user_personality_hash = {}

      if business.nil?
        # Since business is not found in the DB, get data from retrieved source.
        # Only interested in all the customer urls.
        # Retrieve from current page first
        retrieve_users_from_page page, user_urls

        # Get all users for remaining pages
        pages = page.css('a.page-option.available-number')

        # TODO: Uncomment when in production. Avoid calls for now.
        # for i in 0..pages.length-1
        #   # Sleep with given time to avoid being marked as a crawler.
        #   sleep(GET_REQ_TIME)
        #
        #   # Reload the page using the parsed URL
        #   new_url = pages[i]['href']
        #   page = Nokogiri::HTML(open(new_url, Common::CRAWL_USER_AGENT))
        #
        #   # Get all user_ids on the new page.
        #   retrieve_users_from_page page, user_urls
        # end

        # TODO: Perform a personality prediction using the
        #       classification model, passing in the URL of this user.
        user_urls.each_key do |user_url|
          # Sleep with given time to avoid being marked as a crawler.
          sleep(GET_REQ_TIME)

          # Grab the user's information and predict at given URL.  Store in
          # hash.
          get_indep_var(user_url)
          personality = get_prediction()
          puts personality
        end

        # TODO: For all the obtained user info, get summary and store for
        #       the business.
      else
        if update_if_found
          # Since flag to update is true, update record in DB with retrieved
          # data.
        end
      end

      # Obtain all business info
      retrieve_business_info_from_page page, business_hash,
                                       retrieved_bus_id

      # TODO: Get summary using the user_personality_hash and business_hash
      # summarize_and_add_business_to_db
    end
  end

  def retrieve_users_from_page page, user_urls_hash
    users = page.css('a.user-display-name')

    # Store each user_id in the hash, for current page.
    for i in 0..users.length-1
      user_urls_hash["http://www.yelp.com#{users[i]['href']}"] = 0
    end
  end

  def retrieve_business_info_from_page page, business_hash, business_id
    # Initialize the hash for the business_id
    business_hash[business_id] = {}
    
    # Business name
    business_hash[business_id][BUSINESS_INFO_KEYS[:name_key]] =
      page.css('h1.biz-page-title.embossed-text-white').text

    business_hash[business_id][BUSINESS_INFO_KEYS[:stars_key]] =
      page.css("div.biz-main-info meta[itemprop='ratingValue']")[0]['content']

    business_hash[business_id][BUSINESS_INFO_KEYS[:review_count_key]] =
      page.css("div.biz-main-info span[itemprop='reviewCount']").text

    address = page.css("div.media-story address").text
    # Address needs to be split into city, state, and formatted full address.
    # Format: 80 N Market St, San Jose, CA 95113
    address = address.split(',')
    city = address[1]
    state = address[2].split(' ')[1]
    full_address = "#{address[0]}\n#{address[1]},#{address[2]}"

    business_hash[business_id][BUSINESS_INFO_KEYS[:city_key]] = city
    business_hash[business_id][BUSINESS_INFO_KEYS[:state_key]] = state
    business_hash[business_id][BUSINESS_INFO_KEYS[:address_key]] = full_address
  end

  def make_business_link business, business_name
    # Make business link
    res = "<a href=\"#{businesses_path}/#{business.id}\">"
    res << business_name
    res << '</a>'

    return res
  end

  def draw_business_summary_card business
    res =   '<div class="col-xs-12 col-md-6">'
    res <<     '<div class="well well-sm">'
    res <<       '<div class="row">'

    # Add business info
    res <<        add_business_info(business)

    # Add the personality bars and rating
    res <<        add_personality_bars_and_rating(business)

    res <<       '</div>'
    res <<     '</div>'
    res <<   '</div>'

    return res
  end

  def add_business_info business
    res =  '<div class="col-xs-12 col-md-6 text-center">'
    res <<   '<h1 class="bus-info">'
    res <<     '<div class="name">'
    res <<       make_business_link(business, business.name)
    res <<     '</div>'
    res <<   '</h1>'
    res <<   '<h2 class="bus-info">'
    res <<     '<div class="address">'

    # Add the address
    address = business.full_address.split("\n")
    res <<       "<i>#{address[0]}<br>#{address[1]}</i>"
    res <<     '</div>'
    res <<   '</h2>'
    res << '</div>'

    return res
  end

  def add_personality_bars_and_rating business
    res =  '<div class="col-xs-12 col-md-6 text-center">'
    res <<   '<div class="row rating-desc" style="margin-top: 10px">'

    # Now add each of the personality bars.  The num intro/extro will be
    # passed as the value now, and the percentage will be calculated prior
    # to being passed in.
    total_personality = business.num_introverted + business.num_extroverted

    # First, we draw the extroverted:
    res << add_extrovert_personality_bar(total_personality,
                                         business.num_extroverted)

    # Second, draw the introverted:
    res << add_introvert_personality_bar(total_personality,
                                         business.num_introverted)

    res <<   '</div>'

    # Add the rating as stars
    res <<    draw_rating_stars(business.stars)

    # Add the total number of reviews
    res <<   '<div>'
    res <<     '<span class="glyphicon glyphicon-user"></span>'
    res <<        business.review_count.to_s
    res <<   '</div>'
    res << '</div>'

    return res
  end

  def add_extrovert_personality_bar total, num_extroverted
    if total != 0
      percentage = (num_extroverted / total) * 100
    else
      # If no personality, just set as 0.
      percentage = 0
    end

    return draw_personality_bar(num_extroverted, percentage,
                                Personality::EXTROVERTED)
  end

  def add_introvert_personality_bar total, num_introverted
    if total != 0
      percentage = (num_introverted / total) * 100
    else
      # If no personality, just set as 0.
      percentage = 0
    end

    return draw_personality_bar(num_introverted, percentage,
                                Personality::INTROVERTED)
  end

  def draw_personality_bar value_now, width, type
    res =  '<div class="col-xs-3 col-md-3 text-right">'
    res <<   "<span class=\"glyphicon #{Personality::INTRO_EXTRO_GLYPH_TYPE[type]}\"></span>"
    res << '</div>'
    res << '<div class="col-xs-8 col-md-9">'
    res <<   '<div class="progress">'
    res <<     "<div class=\"progress-bar #{Personality::INTRO_EXTRO_BAR_TYPE[type]}\"" \
               "role=\"progressbar\" aria-valuenow=\"#{value_now}\"" \
               "aria-valuemin=\"0\" aria-valuemax=\"100\"" \
               " style=\"width: #{width}%\">"

    res <<       "<span class=\"sr-only\">#{width}%</span>"
    res <<     '</div>'
    res <<   '</div>'
    res << '</div>'

    return res
  end

  def draw_rating_stars rating
    total_stars = 5
    full_stars = (rating / 1).to_i
    enable_half_star = false

    # Sizes are as follows: fa-lg, fa-2x, fa-3x, fa-4x, fa-5x
    star_size = 'fa-2x'

    if (rating - full_stars) >= 0.5
      enable_half_star = true
    end

    res = '<div class="rating">'

    # Draw the full stars
    for i in 0..full_stars-1
      res << "<i class=\"fa fa-star #{star_size}\"></i>"
    end

    if enable_half_star
      res << "<i class=\"fa fa-star-half-o #{star_size}\"></i>"
    end

    # Calculate any empty stars we need to draw.
    remaining_stars = total_stars - full_stars

    # And if half star was enabled, subtract that as well as 1 full star.
    if enable_half_star
      remaining_stars = remaining_stars - 1
    end

    for i in 0..remaining_stars-1
      res << "<i class=\"fa fa-star-o #{star_size}\"></i>"
    end

    res << '</div>'

    return res
  end
end
