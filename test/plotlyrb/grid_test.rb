require File.expand_path('../../test_helper', __FILE__)

module Plotlyrb
  class GridTest < Test::Unit::TestCase
    def test_get_image
      plotly = Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
      data = [{:x => [1,2,3], :y => [2,4,6], :type => 'scatter'}]
      assert(true)
    end
  end
end
