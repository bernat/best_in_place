require 'rails/railtie'

module BestInPlace
  class Railtie < ::Rails::Railtie #:nodoc:
    config.after_initialize do
      ActiveSupport.on_load(:action_view) do
        BestInPlace::ViewHelpers = ActionView::Base.empty
      end
    end
  end
end
