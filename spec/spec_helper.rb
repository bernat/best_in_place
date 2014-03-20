# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../test_app/config/environment', __FILE__)
require 'coveralls'
require "rspec/rails"
require "nokogiri"

Coveralls.wear!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each{|f| require f}

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'

  config.include RSpec::Matchers
  config.include BestInPlace::TestHelpers

  # == Mock Framework
  config.mock_with :rspec
end

Capybara.default_wait_time = 5
