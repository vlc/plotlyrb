require 'net/https'
require 'json'

module Plotlyrb
  class Plot

    def initialize(headers)
      @headers = headers
      @https = Net::HTTP.new(ApiV2::PLOTS.host, ApiV2::PLOTS.port)
      @https.use_ssl = true
    end

    # Takes a list of data hashes (each element is a trace?), response from grid creation, x and y
    # column names (must appear in grid), and a layout. Extracts the column references from the
    # grid response to populate the xsrc # and ysrc fields in data.
    # See https://api.plot.ly/v2/plots#create
    def create_from_grid(data, grid_json, layout = {})
      grid_response_body = JSON.parse(grid_json)
      begin
        payload_data = data.map { |d| self.class.replace_column_names_with_uids(grid_response_body, d) }
      rescue => e
        return Response.fail(e.to_s)
      else
        payload = { :figure => { :data => payload_data, :layout => layout } }.to_json
        request = Net::HTTP::Post.new(ApiV2::PLOTS.path, @headers)
        request.body = payload
        Response.from_http_response(@https.request(request))
      end
    end

    # replace_column_names_with_uids :: Map -> Map -> Either Response Map
    def self.replace_column_names_with_uids(response_body, trace_data)
      raise('No :xsrc key in trace data') unless trace_data.has_key?(:xsrc)
      raise('No :ysrc key in trace data') unless trace_data.has_key?(:ysrc)
      x_uid = column_uid_from_name(response_body, trace_data[:xsrc])
      y_uid = column_uid_from_name(response_body, trace_data[:ysrc])
      trace_data.merge({:xsrc => x_uid, :ysrc => y_uid})
    end

    def self.column_uid_from_name(response_body, name)
      fid = response_body.fetch('file').fetch('fid')
      cols = response_body.fetch('file').fetch('cols')
      maybe_col = cols.select { |c| c.fetch('name') == name.to_s}
      raise("Unable to find column named '#{name.to_s}' in response") if maybe_col.size != 1
      uid = maybe_col.first.fetch('uid')
      "#{fid}:#{uid}"
    end
  end
end
