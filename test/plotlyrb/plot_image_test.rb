require File.expand_path('../../test_helper', __FILE__)
require 'tempfile'

module Plotlyrb
  class PlotImageTest < Test::Unit::TestCase
    TIMEOUT = 5 # seconds

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
      plotly.plot_image(data, tmp_file)
      assert(FileUtils.identical?("#{File.dirname(__FILE__)}/../fixtures/get_test.png", tmp_file), 'File returned should be same')
    end

    # WARNING: this test depends on network AND plotly's service - may fail when code is fine
    def test_plot_images
      num_requests = 5
      spec_paths = (1..num_requests).to_a.map { |i|
        tmp_file = Tempfile.new("get_image_test#{i+1}").path
        PlotImage::SpecPath.new(data, tmp_file)
      }

      results = plotly.plot_images(spec_paths, TIMEOUT)
      num_requests.times { |i|
        assert(results[i].success, "Image returned successfully")
        assert(FileUtils.identical?("#{File.dirname(__FILE__)}/../fixtures/get_test.png", spec_paths[i].path), "File #{i} as expected")
      }
    end

    def test_failed_spec_paths
      fake_results = [[true, 1], [false, 2], [false, 3], [true, 4]].map { |s,n| PlotImage::AsyncJobResult.new(s, n) }
      failures = PlotImage.failed_spec_paths(fake_results)
      assert_equal(2, failures.size)
      assert_equal(Set.new([2,3]), Set.new(failures))
    end
  end
end
