module BestInPlace
  module CheckVersion
    if Rails::VERSION::STRING < "3.1"
      raise "This version of Best in Place is intended to be used for Rails >= 3.1. If you want to use it with Rails 3.0 or lower, please use the rails-3.0 branch."
      return
    end
  end
end
