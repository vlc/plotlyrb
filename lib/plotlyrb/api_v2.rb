require 'net/https'
require 'base64'

module Plotlyrb
  class ApiV2

    PROTOCOL = 'https'
    HOSTNAME = 'api.plot.ly'
    BASE_PATH = 'v2'
    BASE_URI = "#{PROTOCOL}://#{HOSTNAME}/#{BASE_PATH}"

    IMAGES = URI.parse("#{BASE_URI}/images")

    def self.headers(username, api_key)
      encoded_auth = Base64.encode64("#{username}:#{api_key}")
      {
        'plotly-client-platform' => "Ruby #{Plotlyrb::VERSION}",
        'authorization' => "Basic #{encoded_auth}",
        'content-type' => 'application/json'
      }
    end
  end
end