module BestInPlace
  class Railtie < Rails::Railtie
    initializer "set view helpers" do
      ViewHelpers = ActionView::Base.new
    end
  end
end
