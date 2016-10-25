require File.expand_path('../../test_helper', __FILE__)
require_relative './grid_test'

module Plotlyrb
  class PlotTest < Test::Unit::TestCase
    def test_column_uid_from_name
      r = {'file' => {'cols' => [{'name' => 'barry', 'uid' => '123'},
                               {'name' => 'fred',  'uid' => '456'}]}}
      uid = Plot.column_uid_from_name(r, 'barry')
      assert_equal('123', uid, "barry's uid is equal")
    end

    def test_create_from_grid
      plotly = Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
      grid_response = GridTest.create_grid(plotly)
      assert(grid_response.success, 'Plotly says it creatd the grid')

      data = {:type => 'scatter', :name => 'create from grid test'}
      rsp = plotly.create_plot_from_grid(data, grid_response, 'pokemon', 'count')
      p rsp.inspect
      assert(rsp.success, 'Plotly says it created the plot')
    end
  end
end
