module PredictHelper
  def get_search_type query_str
    if query_str.include? 'user_details?userid='
      return "user"
    elsif query_str.include? '/biz/'
      return "business"
    else
      # Other cases we will consider as business, since we allow searching by
      # business name, which will not include /biz/
      return "business"
    end
  end
end
