require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rjb'
require 'common'

class UsersController < ApplicationController
include UsersHelper
  def result
    url = params[:predict_params][:query_str] #Yelp url input
    #Check if http:// is provided
    if !url.match(/^http/)
      url = 'http://' + url
    end
    #parse independent variables stored in @indep_var
    get_indep_var(url)
    result = get_prediction()
    
    if (result == 0.0)
      @data = "Extroverted"
    else
      @data = "Introverted"
    end
  end
end