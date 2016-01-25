module Plotlyrb
  class Plotly
    def initialize(headers)
      @headers = headers
    end

    def plot_image(*args)
      PlotImage.new(@headers).plot_image(*args)
    end
  end
end

