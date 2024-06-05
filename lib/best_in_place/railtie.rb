require 'rails/railtie'
require 'action_view/base'

module BestInPlace
  class Railtie < ::Rails::Railtie #:nodoc:
    config.after_initialize do
      BestInPlace::ViewHelpers = ActionView::Base.respond_to?(:empty) ? ActionView::Base.empty : ActionView::Base.new
    end

    initializer "best_in_place.deprecator" do |app|
      app.deprecators[:best_in_place] = BestInPlace.deprecator if app.respond_to?(:deprecators)
    end
  end
end
