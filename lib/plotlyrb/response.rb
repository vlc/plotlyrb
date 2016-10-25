module Plotlyrb
  class Response < Struct.new(:success, :body, :msg, :errors)
    def self.from_http_response(rsp)
      case rsp.code
      when '200'
        new(true, rsp.body, '200 - OK', [])
      when '201'
        new(true, rsp.body, '201 - CREATED', [])
      when '400'
        new(false, rsp.body, '400 - BAD REQUEST', get_errors(rsp.body))
      when '404'
        new(false, rsp.body, '404 - NOT FOUND', ['Appears we got an endpoint wrong'])
      else
        new(false, rsp.body, "#{rsp.code} - UNHANDLED", ['Unhandled error'])
      end
    end

    # s is a Net::HTTP::Response body we expect to contain JSON map with a list of errors
    def self.get_errors(s)
      msg_key = 'message'
      h = JSON.parse(s)
      es = h['errors']
      if es.nil? || !es.is_a?(Array) || !all_have_key?(es, msg_key)
        return ['Failed to parse plotly error response - check raw body']
      end

      es.map { |e| e.fetch(msg_key) }
    end

    def self.all_have_key?(hs, key)
      hs.all? { |h| h.has_key?(key) }
    end
  end
end
