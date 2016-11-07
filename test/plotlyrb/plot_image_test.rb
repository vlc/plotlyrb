require File.expand_path('../../test_helper', __FILE__)
require 'tempfile'

module Plotlyrb
  class PlotImageTest < Test::Unit::TestCase
    TIMEOUT = 5 # seconds
    DATA = {:figure => {
              :data => [{:x => [1,2,3], :y => [2,4,6], :type => 'scatter'}],
              :layout => {:xaxis => {:title => 'one-two-three'}, :yaxis => {:title => 'two-four-six'}}
            },
            :format => :png
           }

    def plotly
      Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
    end

    def test_get_image
      tmp_file = Tempfile.new('get_image_test').path
      plotly.plot_image(DATA, tmp_file)
      assert(FileUtils.identical?("#{File.dirname(__FILE__)}/../fixtures/get_test.png", tmp_file), 'File returned should be same')
    end

    def test_plot_images
      num_requests = 5
      spec_paths = (1..num_requests).to_a.map { |i|
        tmp_file = Tempfile.new("get_image_test#{i+1}").path
        [DATA, tmp_file]
      }

      results = plotly.plot_images(spec_paths, TIMEOUT)
      num_requests.times { |i|
        assert(results[i].success, "Image returned successfully")
        assert(FileUtils.identical?("#{File.dirname(__FILE__)}/../fixtures/get_test.png", spec_paths[i][1]), "File #{i} as expected")
      }
    end
  end
end
