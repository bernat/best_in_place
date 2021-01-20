module BestInPlace
  class Engine < Rails::Engine
    require 'rails_autosize_jquery'
    initializer 'best_in_place' do
      ActionView::Base.send(:include, BestInPlace::Helper)
      ActionController::Base.send(:include, BestInPlace::ControllerExtensions)
    end
  end
end
