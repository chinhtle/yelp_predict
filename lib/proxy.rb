require 'rubygems'
require 'net/http'
require 'open-uri'
require 'mechanize'

class Proxy
  PROXY_HOST = 'us-il.proxymesh.com'
  PROXY_PORT = 31280
  PROXY_USER = ENV['PROXYMESH_USER']
  PROXY_PASS = ENV['PROXYMESH_PASS']

  FORBIDDEN_REQ_RETRIES = 30

  def initialize(proxy_host = PROXY_HOST, proxy_port = PROXY_PORT,
                 proxy_user = PROXY_USER, proxy_pass = PROXY_PASS)
    @proxy_host =  proxy_host;
    @proxy_port =  proxy_port;
    @proxy_user =  proxy_user;
    @proxy_pass =  proxy_pass;
    @retries = 1
  end

  def request_response(uri_str, limit = 10)
    begin
      page = get_page(uri_str)
      status_code = page.code.to_i

      puts "Received status code: #{status_code}"
    rescue Errno::ETIMEDOUT, Timeout::Error, Mechanize::ResponseCodeError,
           Net::HTTPForbidden
      if @retries < FORBIDDEN_REQ_RETRIES
        puts "Received error.. Retrying. Request num: #{@retries}"
        page = request_response(uri_str)

        @retries += 1
      end
    end

    return page
  end

  def get_page(url)
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    agent.set_proxy(PROXY_HOST, PROXY_PORT, PROXY_USER, PROXY_PASS)
    return agent.get url
  end
end
