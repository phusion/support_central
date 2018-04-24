require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/config_file_loader'
require_relative '../lib/thread_pool'
CONFIG = ConfigFileLoader.new.load

Faraday.default_adapter = :net_http_persistent
if defined?(AwesomePrint)
  AwesomePrint.defaults = {
    :indent => -4
  }
end

module SupportCentral
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W(#{config.root}/app/services)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Amsterdam'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.after_initialize do
      schedulers = {
        GITHUB_SCHEDULER: GithubScheduler,
        SUPPORTBEE_SCHEDULER: SupportbeeScheduler,
        FRONTAPP_SCHEDULER: FrontappScheduler,
        RSS_SCHEDULER: RssScheduler
      }

      if config.cache_classes
        schedulers.each_pair do |name, klass|
          scheduler = klass.new
          Kernel.const_set(name, scheduler)
          if defined?(PhusionPassenger)
            PhusionPassenger.on_event(:starting_worker_process) do |forked|
              scheduler.start_thread
            end
          elsif defined?(Spring)
            Spring.after_fork do
              scheduler.start_thread
            end
          else
            scheduler.start_thread
          end
          at_exit do
            scheduler.shutdown
          end
        end
      end
    end
  end
end
