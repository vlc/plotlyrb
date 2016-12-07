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

    SpecPath = Struct.new(:spec, :path)
    AsyncJobResult = Struct.new(:success, :spec_path)

    class AsyncJob < Struct.new(:thread, :spec_path, :start_time, :timeout)
      def self.from_spec_path(pi, spec_path, timeout)
        thread = Thread.new { pi.plot_image(spec_path.spec, spec_path.path) }
        new(thread, spec_path, Time.new, timeout)
      end

      def join
        now = Time.new
        join_wait = (self.timeout - (now - self.start_time)).to_i + 1
        self.thread.join(join_wait)
        success = File.exist?(spec_path.path) && File.size(spec_path.path) > 1024
        self.thread.exit unless success
        AsyncJobResult.new(success, spec_path)
      end
    end

    # Given [spec, image_path] pairs, run each plot_image request in a separate
    # thread, wait timeout for each, then return list of results. Results flag success
    # and include spec and path from request if user wants to rerun.
    # [(spec, image_path)] -> Integer -> ()
    def self.plot_images(headers, spec_paths, timeout, retries, attempt = 0)
      raise 'Retries must be an integer >= 0' unless (retries.class == Fixnum && retries >= 0)

      return if spec_paths.empty?

      if attempt > retries
        warn("#{spec_paths.size} images not successfully created after #{retries} attempts!")
        return
      end

      async_job_results = spec_paths.map { |sp|
        AsyncJob.from_spec_path(PlotImage.new(headers), sp, timeout)
      }.map(&:join)
      failed_paths = failed_spec_paths(async_job_results)
      plot_images(headers, failed_paths, timeout, retries, attempt + 1)
    end

    # Given a list of AsyncJobResult (return from plot_images), return the SpecPaths that failed
    def self.failed_spec_paths(rs)
      rs.reject(&:success).map(&:spec_path)
    end
  end
end
