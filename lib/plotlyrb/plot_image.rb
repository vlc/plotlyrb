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
      response = Response.from_http_response(@https.request(request))
      IO.binwrite(image_path, response.body) if response.success
      response
    end

    SpecPath = Struct.new(:spec, :path)
    AsyncJobResult = Struct.new(:success, :message, :spec_path)

    class AsyncJob < Struct.new(:thread, :spec_path, :start_time, :timeout)
      def self.from_spec_path(pi, spec_path, timeout)
        thread = Thread.new { pi.plot_image(spec_path.spec, spec_path.path) }
        new(thread, spec_path, Time.new, timeout)
      end

      def join
        now = Time.new
        join_wait = (self.timeout - (now - self.start_time)).to_i + 1

        # Joining should bubble any exceptions, so catch them and report the failure as an error
        begin
          msg = ''
          if thread.join(join_wait).nil?
            msg = "thread didn't finish within timeout (#{timeout}s)"
            thread.exit
          end

          response = thread.value
          unless response.success
            msg = "Plotly returned error response: #{response}"
          end

          unless File.exist?(spec_path.path)
            msg = "Output file (#{spec_path.path}) not found"
          end

          AsyncJobResult.new(msg.empty?, msg, spec_path)
        rescue => e
          AsyncJobResult.new(false, e.message, spec_path)
        end
      end
    end

    # Given [spec, image_path] pairs, run each plot_image request in a separate
    # thread, wait timeout for each, then return list of results. Results flag success
    # and include spec and path from request if user wants to rerun.
    # [(spec, image_path)] -> Integer -> ()
    def self.plot_images(headers, spec_paths, timeout, retries, attempt = 0)
      raise 'Retries must be an integer >= 0' unless (retries.class == Fixnum && retries >= 0)

      return if spec_paths.empty?

      (0..retries).to_a.inject(spec_paths) { |sps, _|
        rs = spec_paths.map { |sp| AsyncJob.from_spec_path(PlotImage.new(headers), sp, timeout) }.
                        map(&:join)
        failed_spec_paths(rs)
      }
    end

    # Given a list of AsyncJobResult (return from plot_images), return the SpecPaths that failed
    def self.failed_spec_paths(rs)
      rs.reject(&:success).map(&:spec_path)
    end
  end
end
