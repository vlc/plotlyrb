require File.expand_path('../../test_helper', __FILE__)

module Plotlyrb
  class GridTest < Test::Unit::TestCase
    def test_create_grid
      plotly = Plotlyrb::ApiV2.auth_plotly(USERNAME, API_KEY)
      data = {
        :cols => {
          :pokemon => {:data => ['bulbasaur', 'charmander', 'squirtle'], :order => 0},
          :count => {:data => [1, 2, 42], :order => 1}
        }
      }
      # no parent - create in root directory for account
      response = plotly.create_grid(data, nil)
      assert(response.success)

      body_hash = nil
      assert_nothing_raised('Can parse JSON in response body') { body_hash = JSON.parse(response.body) }
      assert(body_hash.has_key?('file'), 'Response has file key at root')
      cols = body_hash.fetch('file').fetch('cols')
      assert(cols.any? { |c| c['name'] == 'pokemon' })
      assert(cols.any? { |c| c['name'] == 'count' })
    end
  end
end
