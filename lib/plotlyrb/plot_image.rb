require 'base64'
require 'net/https'
require 'json'

class PlotImage

  VALID_IMAGE_FORMATS = [:png, :svg, :pdf, :eps]
  PLOTLY_CLIENT_PLATFORM = 'Ruby 0.1'
  PLOTLY_API_URI = URI.parse('https://api.plot.ly/v2/images')

  def initialize(username, api_key, url=PLOTLY_API_URI)
    @encoded_auth = Base64.encode64("#{username}:#{api_key}")
    @url = url
    @https = Net::HTTP.new(url.host, url.port)
    @https.use_ssl = true
  end

  def plot_image(data, image_path, image_type, layout = {})
    raise "image_type #{image_type} not supported" unless VALID_IMAGE_FORMATS.include?(image_type)

    payload = { :figure => {:data => data, :layout => layout}, :format => image_type.to_s }.to_json
    headers = {
      'plotly-client-platform' => "Ruby #{Plotlyrb::VERSION}",
      'authorization' => "Basic #{@encoded_auth}",
      'content-type' => 'application/json'
    }
    request = Net::HTTP::Post.new(@url.path, headers)
    request.body = payload
    response = @https.request(request)

    image_path_with_ext = "#{image_path}.#{image_type.to_s}"
    IO.binwrite(image_path_with_ext, response.body)
  end

end
