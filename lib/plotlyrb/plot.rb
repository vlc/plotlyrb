require 'net/https'
require 'json'

module Plotlyrb
  class Plot

    def initialize(headers)
      @headers = headers
      @https = Net::HTTP.new(ApiV2::WEB.host, ApiV2::WEB.port)
      @https.use_ssl = true
    end

    # Takes a data hash, response from grid creation, x and y column names (must appear in grid), and a layout.
    # Extracts the column references from the grid response to populate the xsrc and ysrc fields in data.
    # See https://api.plot.ly/v2/plots#create
    # create_from_grid :: Map -> Plotlyrb::Response -> String -> String -> Map -> Plotlyrb::Response
    def create_from_grid(data, grid_response, x_col, y_col, layout = {})
      x_col_uid = column_uid_from_name(grid_response, x_col)
      y_col_uid = column_uid_from_name(grid_response, y_col)
      payload = { :figure => { :data => data, :layout => layout }, :format => image_type.to_s }.to_json
      request = Net::HTTP::Post.new(ApiV2::WEB.path, @headers)
      request.body = payload
      response = @https.request(request)
      image_path_with_ext = "#{image_path}"
      IO.binwrite(image_path_with_ext, response.body)
    end

    private:
    def column_uid_from_name(response, name)
      cols = response.fetch('file', {}).
                      fetch('cols', [])
      maybe_col = cols.select { |c| c.fetch('name') == name}
      return nil if maybe_col.size != 1
      maybe_col.first.fetch('uid')
    end
  end
end
