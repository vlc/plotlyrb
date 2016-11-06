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

    def plot_image(plot_image_spec, image_path)
      raise 'No :format key in spec' unless plot_image_spec.has_key?(:format)
      raise 'No :figure key in spec' unless plot_image_spec.has_key?(:figure)
      raise ':data key not found at {:figure => {:data => ...}}' unless plot_image_spec[:figure].has_key?(:data)

      image_format = plot_image_spec[:format]
      raise "Image format #{image_format} not supported" unless VALID_IMAGE_FORMATS.include?(image_format.to_sym)

      request = Net::HTTP::Post.new(ApiV2::IMAGES.path, @headers)
      request.body = plot_image_spec.to_json
      response = @https.request(request)
      IO.binwrite(image_path, response.body)
    end

    AsyncJobResult = Struct.new(:success, :spec, :path)

    class AsyncJob < Struct.new(:thread, :spec, :path, :start_time, :timeout)
      def self.from_spec_path(pi, spec, path, timeout)
        thread = Thread.new { pi.plot_image(spec, path) }
        new(thread, spec, path, Time.new, timeout)
      end

      def join
        now = Time.new
        join_wait = (self.timeout - (now - self.start_time)).to_i + 1
        # If join returns nil after the timeout, it means the thread hasn't finished
        r = AsyncJobResult.new(!(self.thread.join(join_wait).nil?), spec, path)
      end
    end

    # Given [spec, image_path] pairs, run each plot_image request in a separate
    # thread, wait timeout for each, then return list of results. Results flag success
    # and include spec and path from request if user wants to rerun.
    # [(spec, image_path)] -> Integer -> ()
    def self.plot_images(headers, spec_path_pairs, timeout)
      spec_path_pairs.
        map { |sp| AsyncJob.from_spec_path(PlotImage.new(headers), sp[0], sp[1], timeout) }.
        inject([]) { |results, j|
          results << j.join
        }
    end
  end
end
