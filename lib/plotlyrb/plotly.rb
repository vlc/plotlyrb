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

    def create_plot_from_grid(*args)
      Plot.new(@headers).create_from_grid(*args)
    end
  end
end

