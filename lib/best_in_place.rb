module BestInPlace
  require "best_in_place/helpers"

  class Engine < ::Rails::Engine
    initializer "setup for rails" do
      ActionView::Base.send(:include, BestInPlace::Helpers)
    end
  end
end
