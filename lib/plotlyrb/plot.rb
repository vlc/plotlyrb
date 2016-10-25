require 'net/https'
require 'json'

module Plotlyrb
  class Plot

    def initialize(headers)
      @headers = headers
      @https = Net::HTTP.new(ApiV2::PLOTS.host, ApiV2::PLOTS.port)
      @https.use_ssl = true
    end

    # Takes a data hash, response from grid creation, x and y column names (must appear in grid), and a layout.
    # Extracts the column references from the grid response to populate the xsrc and ysrc fields in data.
    # See https://api.plot.ly/v2/plots#create
    # create_from_grid :: Map -> Plotlyrb::Response -> String -> String -> Map -> Plotlyrb::Response
    def create_from_grid(data, grid_response, x_col, y_col, layout = {})
      response_json = JSON.parse(grid_response.body)
      x_col_uid = self.class.column_uid_from_name(response_json, x_col)
      y_col_uid = self.class.column_uid_from_name(response_json, y_col)
      all_data = data.merge({:xsrc => x_col_uid, :ysrc => y_col_uid})
      payload = { :figure => { :data => all_data, :layout => layout } }.to_json
      request = Net::HTTP::Post.new(ApiV2::PLOTS.path, @headers)
      request.body = payload
      Response.from_http_response(@https.request(request))
    end

    def self.column_uid_from_name(response_json, name)
      cols = response_json.fetch('file', {}).
                           fetch('cols', [])
      maybe_col = cols.select { |c| c.fetch('name') == name.to_s}
      return nil if maybe_col.size != 1
      maybe_col.first.fetch('uid')
    end
  end
end
