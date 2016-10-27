require 'net/https'
require 'json'

module Plotlyrb
  class Grid
    def initialize(headers)
      @headers = headers
      @https = Net::HTTP.new(ApiV2::GRIDS.host, ApiV2::GRIDS.port)
      @https.use_ssl = true
    end

    # data is a hash that mirrors the format of the data hash in the API
    # https://api.plot.ly/v2/grids#create
    def create(data)
      payload = {:data => data}.to_json
      request = Net::HTTP::Post.new(ApiV2::GRIDS.path, @headers)
      request.body = payload
      Response.from_http_response(@https.request(request))
    end
  end
end
