require 'personality'

class BusinessesController < ApplicationController
  include BusinessesHelper

  def index
  end

  def summary
    # Interpret the business name from post.
    # TODO: For now it has to be an exact match.  Need to accept non-exacts.
    business_name = params[:business_params][:name]

    # Perform a lookup using the business name
    business = Business.find_by(name: business_name)

    # Only proceed if a business was found, otherwise set found to false
    if business.nil?
      @found = false
    else
      @found = true
      #https://developers.google.com/chart/interactive/docs/gallery/piechart?csw=1

      data_table = GoogleVisualr::DataTable.new

      # Go through all the personalities and identify if it exists. If it does
      # then it is added to the pie chart.
      add_personalities_to_data_table(data_table, business)

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
                 # :title => 'My Daily Activities',
                 :pieHole => 0.5, :legend => {position: 'bottom', maxLines: 3},
                 :slices => slice_pastel_colors}

      @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)
    end
  end
end
