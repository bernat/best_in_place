module BestInPlace
  class Railtie < Rails::Railtie
    config.after_initialize do
      BestInPlace::ViewHelpers = ActionView::Base.new
    end
  end
end
