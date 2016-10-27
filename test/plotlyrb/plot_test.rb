require File.expand_path('../../test_helper', __FILE__)
require_relative './grid_test'

module Plotlyrb
  class PlotTest < Test::Unit::TestCase
    def mk_test_grid
      {'file' => {
         'fid' => 'user:idlocal',
         'cols' => [{'name' => 'barry', 'uid' => '123'},
                    {'name' => 'fred',  'uid' => '456'}]}}
    end

    def test_column_uid_from_name
      uid = Plot.column_uid_from_name(mk_test_grid, 'barry')
      assert_equal('user:idlocal:123', uid, "barry's uid is equal")
    end

    def test_replace_column_names_with_uids
      trace = {:xsrc => 'barry', :ysrc => 'fred'}
      result = Plot.replace_column_names_with_uids(mk_test_grid, trace)
      expected = {:xsrc => 'user:idlocal:123', :ysrc => 'user:idlocal:456'}
      assert_equal(expected, result, 'All :xsrc and :ysrc column names replaced with column uids')
    end

    def test_create_from_grid
      plotly = Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
      grid_response = GridTest.create_grid(plotly)
      assert(grid_response.success, 'Plotly says it creatd the grid')

      data = [{:type => 'scatter',
               :name => 'create from grid test',
               :xsrc => 'pokemon',
               :ysrc => 'count'}]
      rsp = plotly.create_plot_from_grid(data, grid_response.body)
      assert(rsp.success, 'Plotly says it created the plot')
    end
  end
end
