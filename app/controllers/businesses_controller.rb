require 'personality'

class BusinessesController < ApplicationController
  include BusinessesHelper
  autocomplete :business, :name, :full => true

  # Business search constants:
  BUSINESS_SEARCH_BY = 'name'
  BUSINESS_SEARCH_ORDER_BY = BUSINESS_SEARCH_BY
  BUSINESS_SEARCH_ORDER_TYPE = 'ASC'
  BUSINESS_SEARCH_ORDER_STR = BUSINESS_SEARCH_ORDER_BY + ' ' +
                              BUSINESS_SEARCH_ORDER_TYPE

  # Pie Chart render type
  PIE_CHART_TYPE_GOOGLE_VISUALR = false

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
      @pie_chart_google_visualr = false

      # Get business information
      @business_name = business.name
      @business_city = business.city
      @business_rating = business.stars
      @business_state = business.state
      @business_dominant = business.dominant_type

      if PIE_CHART_TYPE_GOOGLE_VISUALR
        @@pie_chart_google_visualr = true
        render_google_visualr_chart business
      else
        render_high_charts business
      end
    rescue ActiveRecord::RecordNotFound
      @found = false
    end
  end
end
