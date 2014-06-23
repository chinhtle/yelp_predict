require 'rubygems'
require 'nokogiri'
require 'open-uri'

class UsersController < ApplicationController
  def result
    
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

    #Ruby/#{RUBY_VERSION}
    page = Nokogiri::HTML(open(url, "User-Agent" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)"))
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
  end
end
