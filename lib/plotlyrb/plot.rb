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
      grid_response_body = JSON.parse(grid_response.body)
      x_col_uid = self.class.column_uid_from_name(grid_response_body, x_col)
      y_col_uid = self.class.column_uid_from_name(grid_response_body, y_col)
      return Response.fail("Unable to find #{x_col.to_s} in response") if x_col_uid.nil?
      return Response.fail("Unable to find #{y_col.to_s} in response") if y_col_uid.nil?

      all_data = data.merge({:xsrc => x_col_uid, :ysrc => y_col_uid})
      payload = { :figure => { :data => all_data, :layout => layout } }.to_json
      request = Net::HTTP::Post.new(ApiV2::PLOTS.path, @headers)
      request.body = payload
      Response.from_http_response(@https.request(request))
    end

    def self.column_uid_from_name(response_body, name)
      fid = response_body.fetch('file').fetch('fid')
      cols = response_body.fetch('file').fetch('cols')
      maybe_col = cols.select { |c| c.fetch('name') == name.to_s}
      return nil if maybe_col.size != 1
      uid = maybe_col.first.fetch('uid')
      "#{fid}:#{uid}"
    end
  end
end
