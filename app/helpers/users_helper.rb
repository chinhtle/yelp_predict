module UsersHelper
  #function for adding item to hash
    def add_item(item)
      key = item.gsub(/[^a-z ]/i, '')
      key = key.strip
      value = item.to_i
      if !key.empty?
        @indep_var[key] = value
      end
    end
    
    #function to get sum of ratings for the page
    def get_sum(page)
      sum = 0
      rating = page.css('.rating')
      rating.each do |num|
        stars = num.css('i')[0]['title']
        stars = stars.to_f
        sum += stars
      end 
      return sum
    end
    
    #function set attributes of the instance 
    def set_attribute(inst, loc, key)
      if(@indep_var.has_key?(key))
        inst.setValue(loc, @indep_var[key])
      end
    end
    
    #function for parsing independent variables
    def get_indep_var(url)
      #Get page
      page = Nokogiri::HTML(open(url, Common::CRAWL_USER_AGENT)) 
      #puts page.class   # => Nokogiri::HTML::Document
    
      #user_stats block
      stats = page.css('ul#user_stats')
      length = stats.css('li')
      @indep_var = Hash.new
      for i in 0..length.length-1
        listitem = stats.css('li')[i].text
        add_item(listitem)
      end
    
      #review votes 
      votes = page.css('p#review_votes').text
      if !votes.empty?
        votes_key = votes.split(/[,:]/)
        useful = votes_key[1]
        funny = votes_key[2]
        cool = votes_key[3]
        cool = cool.sub(/and/,'')
        add_item(useful)
        add_item(funny)
        add_item(cool)
      end
    
      #compliments
      compliments = page.css('div#comp_teaser h3 a').text
      add_item(compliments)
    
      #each type of compliment
      block_compliments = page.css('div#userComplimentIcons div')
      block_compliments.each do |n|
        type = n.css('i')[0]['class']
        type = type.split(' ')
        key = type[2].split('-')[1].split('_')[0]
        value = n.text.strip
        @indep_var[key] = value.to_i
      end
    
      #elite
      elite = page.css('ul#elite-badges').css('li')
      @indep_var['elite'] = elite.length
    
      #average_rating
	  if(@indep_var['Reviews'] > 0)
		sum = 0
		#get sum of ratings for the profile home page
		sum = get_sum(page)
		#checks if more button exists
		more_check = "p[style='margin:5px 0px;clear:both;text-align:right;']"
		if(page.at_css(more_check))
			more = page.css(more_check).css('a')[0]['href']
			reviews_url = 'http://www.yelp.com' + more
			more_page = Nokogiri::HTML(open(reviews_url, Common::CRAWL_USER_AGENT))
			#add to the sum of ratings for the page after more is clicked
			sum += get_sum(more_page)
			#check if next button exists
			next_check = 'a#pager_page_next'
			#add the sum of ratings for each next page until there is no more next button
			while(page.at_css(next_check))
			next_page = page.css(next_check)[0]['href']
			next_url = 'http://www.yelp.com' + next_page
			sleep(2)
			page = Nokogiri::HTML(open(next_url, Common::CRAWL_USER_AGENT))
			sum += get_sum(page)
			end
		end
		avg = sum/@indep_var["Reviews"]
		@indep_var["Average"] = avg 
		end
	end
    
    def get_prediction()
      #Load Java Jar
      dir = "#{Rails.root}/public/java/weka.jar"
      #Have Rjb load the jarfile, and pass Java command line arguments
      Rjb::load(dir, jvmargs=["-Xmx1000M"])
      #make k-means classifier
      obj = Rjb::import('weka.core.SerializationHelper')
      #load the model
      file = obj.read("#{Rails.root}/public/randomforest_resampling_filtered.model")
      inst_src = Rjb::import('java.io.FileReader').new("#{Rails.root}/public/unmapped_users.arff")
      instances = Rjb::import('weka.core.Instances').new(inst_src)
      idx = instances.numAttributes() - 1
      instances.setClassIndex(idx)
      first = Rjb::import('weka.core.Instance')
      first = instances.instance(0)
      #set the instance to be evaluated by the model
      set_attribute(first, 0, "Funny")
      set_attribute(first, 1, "Useful")
      set_attribute(first, 2, "Cool")
      set_attribute(first, 3, "Reviews")
      set_attribute(first, 4, "Friends")
      set_attribute(first, 5, "Fans")
      set_attribute(first, 6, "Average")
      set_attribute(first, 7, "Compliments")
      set_attribute(first, 8, "elite")
      set_attribute(first, 9, "profile")
      set_attribute(first, 10, "cute")
      set_attribute(first, 11, "funny")
      set_attribute(first, 12, "plain")
      set_attribute(first, 13, "writer")
      set_attribute(first, 14, "list")
      set_attribute(first, 15, "note")
      set_attribute(first, 16, "photos")
      set_attribute(first, 17, "hot")
      set_attribute(first, 18, "more")
      set_attribute(first, 19, "cool")
      file.classifyInstance(first);
      test_set = Rjb::import('weka.classifiers.Evaluation').new(instances)
      #get the prediction
      result = test_set.evaluateModelOnceAndRecordPrediction(file, first)
	  if (result == 0.0)
		result = "Extroverted"
		else
		result = "Introverted"
	  end
      return result
    end
end
