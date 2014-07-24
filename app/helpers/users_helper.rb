require 'common'
require 'proxy'

module UsersHelper
  # Flag to enable delaying of page requests.
  DELAY_REVIEW_PAGE_REQUESTS = false

  #function for adding item to hash
    def add_item(item)
      key = item.gsub(/[^a-z ]/i, '')
      key = key.strip
	  key = key.gsub(/s$/, '')
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
	  else
        @indep_var[key] = 0
      end
    end
    
    #function for parsing independent variables
    def get_indep_var(url)
      #Get page
      if url == "http://www.yelp.com/user_details?userid=local"
        url = "#{Rails.root}/yelp_data/offline/users/yelp_home.htm"
      end

      proxy = Proxy.new
      result = proxy.request_response(url)
      page = Nokogiri::HTML(result.body, 'UTF-8')

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
	  if(@indep_var['Review'] > 0)
		sum = 0
		local_num = 3
		#get sum of ratings for the profile home page
		sum = get_sum(page)
		#checks if more button exists
		more_check = "p[style='margin:5px 0px;clear:both;text-align:right;']"
		if(page.at_css(more_check))
			more = page.css(more_check).css('a')[0]['href']
      if url == "http://www.yelp.com/user_details?userid=local"
        reviews_url = "#{Rails.root}/yelp_data/offline/users/more_page.htm"
      else
        reviews_url = 'http://www.yelp.com' + more
      end

      result = proxy.request_response(reviews_url)
      more_page = Nokogiri::HTML(result.body, 'UTF-8')

			#add to the sum of ratings for the page after more is clicked
			sum += get_sum(more_page)
			#check if next button exists
			next_check = 'a#pager_page_next'
			#add the sum of ratings for each next page until there is no more next button
			while(more_page.at_css(next_check))
			next_page = more_page.css(next_check)[0]['href']
			if url == "http://www.yelp.com/user_details?userid=local"
				local_next = 'page_' + local_num.to_s + '.htm'
				next_url = "#{Rails.root}/yelp_data/offline/users/" + local_next
			else
				next_url = 'http://www.yelp.com' + next_page
			end
      if DELAY_REVIEW_PAGE_REQUESTS
			  sleep(Common::GET_REQ_TIME)
      end
      result = proxy.request_response(next_url)
      more_page = Nokogiri::HTML(result.body, 'UTF-8')
			sum += get_sum(more_page)
			local_num = local_num + 1
			end
		end
		avg = sum/@indep_var["Review"]
		avg = avg.round(1)
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
      set_attribute(first, 3, "Review")
      set_attribute(first, 4, "Friend")
      set_attribute(first, 5, "Fan")
      set_attribute(first, 6, "Average")
      set_attribute(first, 7, "Compliment")
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
      result = test_set._invoke('evaluateModelOnceAndRecordPrediction', 'Lweka.classifiers.Classifier;Lweka.core.Instance;', file, first)
      if (result == 0.0)
        result = "Extroverted"
      else
        result = "Introverted"
      end
      return result
    end

  def draw_num_attributes_card indep_variables
    puts "Indep variables: #{indep_variables}"

    res =   '<div class="col-xs-12 col-md-9 col-centered">'
    res <<     '<div class="well well-lg">'
    res <<       '<div class="row">'
    res <<         add_attr_card_header
    res <<         add_separator('header')

    # Add attributes
    res <<         add_attr_value_col('Number of Friends',
                                      indep_variables['Friend'].to_s)
    res <<         add_separator('normal')

    res <<         add_attr_value_col('Number of Reviews',
                                      indep_variables['Review'].to_s)
    res <<         add_separator('normal')

    res <<         add_attr_value_col('Number of Fans',
                                      indep_variables['Fan'].to_s)
    res <<         add_separator('normal')

    res <<         add_attr_value_col('Number of Times Elite',
                                      indep_variables['elite'].to_s)
    res <<         add_separator('normal')

    res <<         add_attr_value_col('Average Rating Given',
                                      "<div class=\"rating\">
                                      #{Common::draw_stars(
                                        indep_variables['Average'], 1)}</div>")
    res <<         add_separator('normal')

    res <<         add_attr_value_col('Number of Compliments',
                                      indep_variables['Compliment'].to_s)

    # Add compliments and votes received
    res <<         draw_compliments_votes_card(indep_variables)

    res <<       '</div>'
    res <<     '</div>'
    res <<   '</div>'

    return res.html_safe
  end

  def add_attr_value_col attr, val
    puts "Attribute: #{attr}, value: #{val}"

    res =  '<div class="row">'
    res <<   '<div class="col-xs-12 col-md-7 col-user-attr-title">'
    res <<     "<b>#{attr}</b>"
    res <<   '</div>'
    res <<   '<div class="col-xs-12 col-md-5 col-user-attr-value">'
    res <<     val
    res <<   '</div>'
    res << '</div>'
  end

  def add_attr_card_header
    res =   '<h2>'
    res <<    '<div class="col-header">'
    res <<      'What variables determined your personality?'
    res <<    '</div>'
    res <<  '</h2>'

    return res
  end

  def add_separator type
    return "<div class=\"col-row-separator-#{type}\"></div>"
  end

  def add_inner_separator type
    return "<div class=\"col-inner-row-separator-#{type}\"></div>"
  end

  def draw_compliments_votes_card indep_variables
    res =  '<div class="row">'
    res <<   '<div class="well-inner">'
    res <<     add_compliments_attrs(indep_variables)
    res <<     add_inner_separator('header')
    res <<     add_votes_attrs(indep_variables)
    res <<   '</div>'
    res << '</div>'
  end

  def draw_glyph_value glyph, val, tooltip
    res =  '<div class="compliment-attr">'
    res <<   "<span class=\"function\" data-content=\"#{tooltip}\">"
    res <<     "<i class=\"fa fa-#{glyph} compliment-glyph\"></i>"
    res <<     "<div>#{val}</div>"
    res <<   '</span>'
    res << '</div>'

    return res
  end

  def add_compliments_attrs indep_variables
    res =   add_inner_well_header 'Compliments Received'
    res <<  draw_glyph_value('user', indep_variables['profile'], 'Like Your Profile')
    res <<  draw_glyph_value('heart', indep_variables['cute'], 'Cute Pic')
    res <<  draw_glyph_value('smile-o', indep_variables['funny'], "You're Funny")
    res <<  draw_glyph_value('gift', indep_variables['plain'], 'Thank You')
    res <<  draw_glyph_value('pencil', indep_variables['writer'], 'Good Writer')
    res <<  draw_glyph_value('list', indep_variables['list'], 'Great Lists')
    res <<  draw_glyph_value('file-o', indep_variables['note'], 'Just a Note')
    res <<  draw_glyph_value('picture-o', indep_variables['photos'], 'Great Photo')
    res <<  draw_glyph_value('fire', indep_variables['hot'], 'Hot Stuff')
    res <<  draw_glyph_value('plus', indep_variables['more'], 'Write More')
    res <<  draw_glyph_value('cloud', indep_variables['cool'], "You're Cool")

    return res
  end

  def add_inner_well_header header
    res =   '<div class="compliment-header">'
    res <<    header
    res <<  '</div>'
    res <<  add_inner_separator('normal')

    return res
  end

  def add_votes_attrs indep_variables
    res =   add_inner_well_header 'Votes Received'
    res <<  draw_glyph_value('thumbs-up', indep_variables['Useful'], 'Useful')
    res <<  draw_glyph_value('smile-o', indep_variables['Funny'], 'Funny')
    res <<  draw_glyph_value('cloud', indep_variables['Cool'], 'Cool')

    return res
  end
end

