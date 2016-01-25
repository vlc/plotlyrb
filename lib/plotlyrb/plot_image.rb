require 'net/https'
require 'json'

module Plotlyrb
  class PlotImage

    VALID_IMAGE_FORMATS = [:png, :svg, :pdf, :eps]

    def initialize(headers)
      @headers = headers
      @https = Net::HTTP.new(ApiV2::IMAGES.host, ApiV2::IMAGES.port)
      @https.use_ssl = true
    end

    def plot_image(data, image_path, image_type, layout = {})
      raise "image_type #{image_type} not supported" unless VALID_IMAGE_FORMATS.include?(image_type)
      payload = { :figure => { :data => data, :layout => layout }, :format => image_type.to_s }.to_json
      request = Net::HTTP::Post.new(ApiV2::IMAGES.path, @headers)
      request.body = payload
      response = @https.request(request)
      image_path_with_ext = "#{image_path}"
      IO.binwrite(image_path_with_ext, response.body)
    end
  end
end