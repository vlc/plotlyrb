module Plotlyrb
  class Plotly
    def initialize(headers)
      @headers = headers
    end

    def plot_image(*args)
      PlotImage.new(@headers).plot_image(*args)
    end

    def create_grid(*args)
      Grid.new(@headers).create(*args)
    end

    def create_plot(*args)
      Plot.new(@headers).create(*args)
    end
  end
end

