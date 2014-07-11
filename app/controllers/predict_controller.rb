class PredictController < ApplicationController
  include PredictHelper

  def delegate
    # From the input string, detect whether it should be routed to user or
    # business.
    type = get_search_type params[:predict_params][:query_str]

    if type == "user"
      redirect_to user_result_path params
    elsif type == "business"
      redirect_to business_results_url params
    end
  end
end
