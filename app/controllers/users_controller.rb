require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rjb'

class UsersController < ApplicationController
  def result
=begin
    #function for adding item to hash
    def add_item(item)
      key = item.gsub(/[^a-z ]/i, '')
      key = key.strip
      value = item.to_i
      if !key.empty?
        @data[key] = value
      end
    end
    
    url = params[:url][:url] #Yelp url input
    #Check if http:// is provided
    if !url.match(/^http/)
      url = 'http://' + url
    end
    #Get page
    page = Nokogiri::HTML(open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}"))    
    puts page.class   # => Nokogiri::HTML::Document
    
    #user_stats block
    stats = page.css('ul#user_stats')
    length = stats.css('li')
    @data = Hash.new
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
=end
    #Load Java Jar
    dir = "#{Rails.root}/public/java/weka.jar"
    #Have Rjb load the jarfile, and pass Java command line arguments
    Rjb::load(dir, jvmargs=["-Xmx1000M"])
    #make k-means classifier
    obj = Rjb::import('weka.core.SerializationHelper')
    file = obj.read("#{Rails.root}/public/rftest.model")
    puts file.toString()
    labor_src = Rjb::import('java.io.FileReader').new("#{Rails.root}/public/user_mapped_nominal_randomize_testing.arff")
    instances = Rjb::import('weka.core.Instances').new(labor_src)
    idx = instances.numAttributes() - 1
    instances.setClassIndex(idx)
    last = Rjb::import('weka.core.Instance')
    last = instances.instance(0)
    #last = instances.lastInstance()
    puts last.toString()
    num = instances.numInstances()
    puts num
    last.setValue(0, 2)
    last.setValue(1, 2)
    last.setValue(2, 2)
    last.setValue(3, 5)
    last.setValue(4, 200)
    last.setValue(5, 50)
    last.setValue(6, 4.5)
    last.setValue(7, 50)
    last.setValue(8, 2)
    last.setValue(9, '1')
    test_set = Rjb::import('weka.classifiers.Evaluation').new(instances)
    result = test_set.evaluateModelOnceAndRecordPrediction(file, last)
    @data = result
  end
end
