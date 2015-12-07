require 'rails/railtie'
require 'action_view/railtie'
require 'action_controller/railtie'

module BestInPlace
  def self.configure
    @configuration ||= Configuration.new
    yield @configuration if block_given?
  end

  def self.method_missing(method_name, *args, &block)
    @configuration.respond_to?(method_name) ?
        @configuration.send(method_name, *args, &block) : super
  end

  class Configuration
    attr_accessor :container, :skip_blur, :default_max_execution_time_in_seconds

    def initialize
      @container = :span
      @skip_blur = false
      @default_max_execution_time_in_seconds = 30
    end
  end

  configure
end

require 'best_in_place/engine'
require 'best_in_place/utils'
require 'best_in_place/helper'
require 'best_in_place/railtie'
require 'best_in_place/controller_extensions'
require 'best_in_place/display_methods'
