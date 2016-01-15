require 'base64'
require 'net/https'
require 'json'

class PlotImage

  VALID_IMAGE_FORMATS = [:png, :svg, :pdf, :eps]
  PLOTLY_CLIENT_PLATFORM = 'Ruby 0.1'
  PLOTLY_API_URI = URI.parse('https://api.plot.ly')
  PLOTLY_VERSION = 'v2'
  PLOTLY_IMAGE_PATH = 'images'

  def initialize(username, api_key)
    @encoded_auth = Base64.encode64("#{username}:#{api_key}")
    @https = Net::HTTP.new(PLOTLY_API_URI.host, PLOTLY_API_URI.port)
    @https.use_ssl = true
  end

  def plot_image(data, image_path, image_type, layout = {})
    raise "image_type #{image_type} not supported" unless VALID_IMAGE_FORMATS.include?(image_type)

    payload = { :figure => {:data => data, :layout => layout}, :format => image_type.to_s }.to_json
    headers = {
      'plotly-client-platform' => PLOTLY_CLIENT_PLATFORM,
      'authorization' => "Basic #{@encoded_auth}",
      'content-type' => 'application/json'
    }
    request = Net::HTTP::Post.new([PLOTLY_API_URI, PLOTLY_VERSION, PLOTLY_IMAGE_PATH].join('/'), headers)
    request.body = payload
    response = @https.request(request)

    # No IO::binwrite :(
    image_path_with_ext = "#{image_path}.#{image_type.to_s}"
    File.open(image_path_with_ext, 'wb') { |file|
      file.write(response.body)
    }
  end

end
