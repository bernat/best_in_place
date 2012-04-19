module BestInPlace
  class Railtie < Rails::Railtie
    initializer "set view helpers" do
      BestInPlace::ViewHelpers = ActionView::Base.new
    end
  end
end