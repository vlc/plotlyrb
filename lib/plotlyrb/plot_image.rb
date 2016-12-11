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

        def fail(msg)
          AsyncJobResult.new(false, msg, spec_path)
        end

        # Joining should bubble any exceptions, so catch them and report the failure as an error
        begin
          msg = ''
          if thread.join(join_wait).nil?
            thread.exit
            return fail("thread didn't finish within timeout (#{timeout}s)")
          end

          response = thread.value
          unless response.success
            return fail("Plotly returned error response: #{response}")
          end

          unless File.exist?(spec_path.path)
            return fail("Output file (#{spec_path.path}) not found")
          end
        rescue => e
          return fail(e.message)
        end

        AsyncJobResult.new(true, '', spec_path)
      end
    end

    # Given an array of SpecPaths, run each plot_image request in a separate thread, wait timeout
    # for each, then return AsyncJobResults for any inputs that failed after the given number of
    # retries
    def self.plot_images(headers, spec_paths, timeout, retries)
      raise 'Retries must be an integer >= 0' unless (retries.class == Fixnum && retries >= 0)
      return [] if spec_paths.empty?

      input_results = spec_paths.map { |sp| AsyncJobResult.new(false, 'not run yet', sp) }
      (0..retries).to_a.inject(input_results) { |ajrs, _|
        # While you might be tempted to fuse these map calls, we want all the jobs to get started
        # before we start joining them, so don't do that.
        rs = ajrs.map { |ajr| AsyncJob.from_spec_path(PlotImage.new(headers), ajr.spec_path, timeout) }.
                  map(&:join).
                  reject(&:success)
      }
    end
  end
end
