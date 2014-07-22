class PredictController < ApplicationController
  include PredictHelper

  def delegate
    # From the input string, detect whether it should be routed to user or
    # business.
    # First, make sure we strip the query string of any leading/trailing
    # whitespaces, before we try to process it.
    params[:predict_params][:query_str] =
        params[:predict_params][:query_str].strip
    type = get_search_type params[:predict_params][:query_str]

    if type == "user"
      redirect_to user_result_path params
    elsif type == "business"
      redirect_to business_results_url params
    end
  end
end
