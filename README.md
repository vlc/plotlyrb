# Plotlyrb

Use [plotly](https://plot.ly) to graph your data.

Currently only supports `plot_image`, which uses the REST API to generate an image for your plot. See [the python reference](https://plot.ly/python/reference/) for details on what you can plot.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plotlyrb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install plotlyrb

## Usage

```ruby
  data = {
  :x => ['2013-10-04 22:23:00', '2013-11-04 22:23:00', '2013-12-04 22:23:00'],
  :y => [1, 3, 6],
  :type => 'scatter'
}

layout = { :xaxis => { :title => 'times' },
           :yaxis => { :title => 'bigfoot sightings', :range => [0, 7] },
}

plotly = Plotlyrb::PlotImage.new('my-plotly-username', 'my-plotly-api-key')
plotly.plot_image(data, 'plot.png', :png, layout)
```

## TODO
- [ ] Support height and width
- [ ] Test more plot types
- [ ] Use data structures/abstractions for plot types, data, etc. ?

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/plotlyrb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

