require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Weby
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/lib
      #{config.root}/app/models/concerns
      #{config.root}/app/controllers/concerns
    )
    config.autoload_paths += Dir["#{config.root}/lib/weby/components/**/*"]
    config.autoload_paths += Dir["#{config.root}/vendor/engines/*/lib/weby/components/**/*"]
    
    # Activate observers that should always be running.
    config.active_record.observers = :page_position_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir["#{config.root}/**/locales/**/*.yml"]
    config.i18n.default_locale = 'pt-BR'

    I18n.enforce_available_locales = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password << :password_confirmation

    # Enable the asset pipeline
    config.assets.enabled = true

    # Weby configs
    config.assets.initialize_on_precompile = true # Bad config?

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.precompile << Proc.new { |path| !path.match(/bootstrap/) }

    config.i18n.fallbacks = true

    # Usando generator mais limpo, desse modo é criado o arquivo só quando necessário
    # ajuda a evitar arquivos desnecessário
    config.generators do |g|
      g.helper false
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec,
        :fixtures => false,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => false,
        :request_specs => false
    end

    # Especificando o layout correto nos controllers do devise
    config.to_prepare do
      Devise::RegistrationsController.layout 'weby_sessions'
      Devise::PasswordsController.layout 'weby_sessions'
      Devise::ConfirmationsController.layout 'weby_sessions'
      Devise::UnlocksController.layout 'weby_sessions'
    end
  end
end
