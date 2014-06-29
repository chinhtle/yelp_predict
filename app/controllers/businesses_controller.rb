require 'personality'

class BusinessesController < ApplicationController
  include BusinessesHelper

  # Business search constants:
  BUSINESS_SEARCH_BY = 'name'
  BUSINESS_SEARCH_ORDER_BY = BUSINESS_SEARCH_BY
  BUSINESS_SEARCH_ORDER_TYPE = 'ASC'
  BUSINESS_SEARCH_ORDER_STR = BUSINESS_SEARCH_ORDER_BY + ' ' +
                              BUSINESS_SEARCH_ORDER_TYPE

  def index
  end

  def results
    # Interpret the business name from post.
    @business_name = params[:business_params][:name]

    # Perform a lookup using the business name.  This will also have partial
    # matching.
    @search_results = Business.where("lower(#{BUSINESS_SEARCH_BY}) LIKE ?",
                                     "%#{@business_name.downcase}%").order(
                                       BUSINESS_SEARCH_ORDER_STR)

    # If only 1 result, go directly to summary
    if @search_results && @search_results.count == 1
      curr_business = @search_results.first
      redirect_to "#{businesses_path}/#{curr_business.id}"
    end
  end

  def show
    begin
      # Perform a search given the internally assigned business_id.
      business = Business.find(params[:id])

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
                 :pieHole => 0.5, :legend => {position: 'bottom', maxLines: 3},
                 :slices => slice_pastel_colors}

      @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)
    rescue ActiveRecord::RecordNotFound
      @found = false
    end
  end
end
