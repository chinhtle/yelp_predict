require 'rubygems/package'
require 'zlib'
require 'json'
require 'csv'
require 'personality'

module BusinessesHelper
  CURR_DIR = File.dirname(__FILE__)
  DATA_PATH = File.join(CURR_DIR, '../../yelp_data')
  BUSINESS_DATA_PATH = "#{DATA_PATH}/business_data"

  # Business Data Set Constants
  DATASET_PREFIX = 'yelp_business_data_set'
  COMPRESSED_EXT = 'tar.gz'
  EXTRACTED_DATA_EXT = 'json'
  EXTRACTED_DATA_FILE_OPTIONS = 'a+' # Reading and appending. Create if needed
  EXTRACTED_FILENAME = "#{DATASET_PREFIX}.#{EXTRACTED_DATA_EXT}"
  EXTRACTED_FILEPATH = "#{BUSINESS_DATA_PATH}/#{EXTRACTED_FILENAME}"

  # Hash Key Constants
  HASH_KEY_BUSINESS_ID = 'business_id'
  HASH_KEY_USER_ID = 'user_id'

  # User Data Set Constants
  USER_DATA_FILENAME = 'user.csv'
  USER_DATA_FILEPATH = "#{DATA_PATH}/#{USER_DATA_FILENAME}"
  USER_ID_CSV_NAME = HASH_KEY_USER_ID
  USER_PERSONALITY_CSV_NAME = 'personality'

  # Personality Summary Constants. P = Personality.
  P_HIGHEST_TYPE_KEY = 'highest_type'
  P_HIGHEST_VALUE_KEY = 'highest_value'

  # Used to decide when feedback prints should be printed
  FEEDBACK_PRINT_THRESH = 10000

  def load_bus_data
    puts 'Loading business data..'

    # Extract data sets first, and proceed only if successful
    if extract_data_sets
      puts 'Extract successful. Proceeding to load from extracted JSON file'
      business_customers_hash = {}
      customer_personality_hash = {}

      # Load the business JSON
      load_json_to_hash(business_customers_hash,
                        EXTRACTED_FILEPATH,
                        HASH_KEY_BUSINESS_ID,
                        HASH_KEY_USER_ID)

      # Now that we know which users are associated with the businesses,
      # read in from the users data set file to obtain their associated
      # personalities.
      load_csv_to_hash(customer_personality_hash,
                       USER_DATA_FILEPATH)

      # Associate the business and customer personality hashes.  Store
      # the personality into the business customer hash
      retrieve_user_personality(business_customers_hash,
                                customer_personality_hash)

      # Now that the data is associated, we can pass the hash of users
      # with their personality to the method to obtain a summary of the types
      # of personalities for the business.
      summarize_and_add_business_to_db(business_customers_hash)
    end

    puts 'Loaded all data successfully.'

    # Remember to delete the extracted data set
    delete_extracted_data
  end

  def summarize_and_add_business_to_db(business_hash)
    puts 'Summarizing and adding business to DB..'

    # Create a temporary hash used for the output of the summary
    tmp_hash = {}

    # Go through each business and get the summary of the personality types
    # and add it to the business database.
    business_hash.each do |business_id, user_hash|
      get_personality_summary_hash(user_hash, tmp_hash)

      # Add the new entry to the table
      # Business.new(id:              business_id,
      #              dominant_type:   tmp_hash[P_HIGHEST_TYPE_KEY],
      #              dominant_value:  tmp_hash[P_HIGHEST_VALUE_KEY],
      #              prosocial:       tmp_hash[Personality::PROSOCIAL],
      #              risktaker:       tmp_hash[Personality::RISK_TAKER],
      #              anxious:         tmp_hash[Personality::ANXIOUS],
      #              passive:         tmp_hash[Personality::PASSIVE],
      #              perfectionist:   tmp_hash[Personality::PERFECTIONIST],
      #              critical:        tmp_hash[Personality::CRITICAL],
      #              conscientious:   tmp_hash[Personality::CONSCIENTIOUS],
      #              openminded:      tmp_hash[Personality::OPEN_MINDED],
      #              intuitive:       tmp_hash[Personality::INTUITIVE],
      #              liberal:         tmp_hash[Personality::LIBERAL])
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
        users_hash[user] = personality
      end
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
      exit(-1)
    end
  end

  def load_json_to_hash(hash, filepath, primary_key, secondary_key)
    puts "Loading JSON to hash. Primary: #{primary_key}, " \
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
          hash[key][value] = 0 # Just make sure value is added as key to hash
        else
          hash[key] = Hash.new
          hash[key][value] = 0
        end

        print_idx += 1
      end

      puts '' # Newline after the feedback prints.
    else
      puts 'Could not open file'
      exit(-1)
    end
  end

  # Requires a hash of users and their personalities.
  def get_personality_summary_hash(users_personality_hash, out_hash)
    # Make sure to initialize the hash and highest personality values
    out_hash = Hash.new(0)

    # Each personality will be recorded as
    # tallies only.  Don't need to retrieve as percentage.
    users_personality_hash.each_value do |personality_enum|
      # Each personality is stored as an enum, so we will use that as key
      out_hash[personality_enum] += 1

      # Record the highest value and type
      if out_hash[personality_enum] > out_hash[P_HIGHEST_VALUE_KEY]
        # personality_type_str = Personality.personality_to_str(personality_enum)
        #
        # puts "Highest personality type: #{personality_type_str}, " \
        #      "value: #{out_hash[personality_enum]}"

        # Update the new highest personality type/value
        out_hash[P_HIGHEST_TYPE_KEY] = personality_enum
        out_hash[P_HIGHEST_VALUE_KEY] = out_hash[personality_enum]
      end
    end
  end

  def extract_data_sets
    puts "Extracting data sets from path: #{BUSINESS_DATA_PATH}"

    # Since there are more than one data set, identify how many files are in
    # the business data path.
    num_files = Dir.glob(File.join(BUSINESS_DATA_PATH, '**', '*')).select {
                  |file| File.file?(file)
                }.count

    if num_files > 0
      index = 1 # Files start at 1 base

      # Create the single JSON file to write to
      extracted_file = File.open(EXTRACTED_FILEPATH,
                                 EXTRACTED_DATA_FILE_OPTIONS)

      while index <= num_files do
        # Iterate through each tar
        file_path = "#{BUSINESS_DATA_PATH}/" \
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
    else
      puts "Could not find #{EXTRACTED_FILEPATH} for deletion"
    end
  end
end
