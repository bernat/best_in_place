require 'rails/railtie'
require 'action_view/railtie'
require 'action_controller/railtie'

module BestInPlace
    def self.deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("1.0", "BestInPlace")
    end

  def self.configure
    @configuration ||= Configuration.new
    yield @configuration if block_given?
  end

  def self.method_missing(method_name, *args, &block)
    @configuration.respond_to?(method_name) ?
        @configuration.send(method_name, *args, &block) : super
  end

  class Configuration
    attr_accessor :container, :skip_blur

    def initialize
      @container = :span
      @skip_blur = false
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
