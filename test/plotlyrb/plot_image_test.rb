require File.expand_path('../../test_helper', __FILE__)
require 'tempfile'

module Plotlyrb
  class PlotImageTest < Test::Unit::TestCase
    RETRIES = 0
    TIMEOUT = 5 # seconds
    EXPECTED_IMAGE = "#{File.dirname(__FILE__)}/../fixtures/get_test.png"

    def data
      {:figure => {
         :data => [{:x => [1,2,3], :y => [2,4,6], :type => 'scatter'}],
         :layout => {:xaxis => {:title => 'one-two-three'}, :yaxis => {:title => 'two-four-six'}}
       },
       :format => :png
      }
    end

    def plotly
      Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
    end

    # WARNING: this test depends on network AND plotly's service - may fail when code is fine
    def test_get_image
      tmp_file = Tempfile.new('get_image_test').path
      response = plotly.plot_image(data, tmp_file)
      assert(response.success)
      assert(FileUtils.identical?(EXPECTED_IMAGE, tmp_file), 'File returned should be same')
    end

    # WARNING: this test depends on network AND plotly's service - may fail when code is fine
    def test_plot_images
      num_requests = 5
      spec_paths = (1..num_requests).to_a.map { |i|
        tmp_file = Tempfile.new("get_image_test#{i+1}").path
        PlotImage::SpecPath.new(data, tmp_file)
      }

      failures = plotly.plot_images(spec_paths, TIMEOUT, RETRIES)
      assert(failures.empty?, 'No failures')
      spec_paths.each { |sp|
        assert(FileUtils.identical?(EXPECTED_IMAGE, sp.path), "File '#{sp.path}' as expected")
      }
    end
  end
end
