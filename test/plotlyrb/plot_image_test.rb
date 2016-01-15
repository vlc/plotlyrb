require File.expand_path('../../test_helper', __FILE__)

module Plotlyrb
  class PlotImageTest < Test::Unit::TestCase
    def test_get_image
      plotly = PlotImage.new(USERNAME, API_KEY)
      data = [{:x => [1,2,3], :y => [2,4,6], :type => 'scatter'}]
      # plotly.plot_image(data, '/tmp/out', :png)
    end
  end
end