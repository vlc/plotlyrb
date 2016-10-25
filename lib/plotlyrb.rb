require 'backports' if RUBY_VERSION < '1.9.3'

require_relative 'plotlyrb/version'
require_relative 'plotlyrb/api_v2'
require_relative 'plotlyrb/response'
require_relative 'plotlyrb/plot_image'
require_relative 'plotlyrb/grid'
require_relative 'plotlyrb/plotly'
