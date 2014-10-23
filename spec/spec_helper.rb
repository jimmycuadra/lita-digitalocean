require "simplecov"
require "coveralls"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start { add_filter "/spec/" }

require "lita-digitalocean"
require "lita/rspec"

Lita.version_3_compatibility_mode = false

RSpec.configure do |config|
  config.before do
    registry.register_hook(:trigger_route, Lita::Extensions::KeywordArguments)
  end
end
