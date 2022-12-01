require 'combustion'
require 'capybara/rspec'
require 'capybara/poltergeist'

require_relative 'support/screenshot'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false, inspector: true})
end
Capybara.javascript_driver = :poltergeist

require 'best_in_place'

Combustion.initialize! :active_record, :action_controller, :action_view, :sprockets do
  config.assets.compile = true
  config.assets.compress = false
  config.assets.debug = false
  config.assets.digest = false
end

require 'rspec/rails'
require 'capybara/rails'

require 'best_in_place/test_helpers'
require_relative 'support/retry_on_timeout'

RSpec.configure do |config|
  config.include BestInPlace::TestHelpers
  config.use_transactional_fixtures = false
  config.raise_errors_for_deprecations!
  config.example_status_persistence_file_path = "failifier.txt"

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
