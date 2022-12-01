if ENV['dev']
  Rails.application.configure do
    config.assets.enabled = true
    config.cache_classes = false
    config.eager_load = false
    config.assets.debug = false
  end
end
I18n.enforce_available_locales = true
