require 'net/http'
require 'uri'

class HTTPHelper

  def initialize
    @host_name =
    @api_url = 'https://csapi.singlecare.com/services/v1_0/private/CRMService.svc/'
  end

  def post(service, params)
    headers = {"Content-Type" => "application/json"}
    begin
      uri = URI.parse(@api_url + service)
      Net::HTTP.post(uri, params, headers)
    rescue Net::HTTPError => exception
      puts exception.message
    end
  end

end
