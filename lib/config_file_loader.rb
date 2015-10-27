require 'yaml'

class ConfigFileLoader
  DEFAULT_PHUSION_GITHUB_USERS = [
    'FoobarWidget',
    'OnixGH'
  ]

  def load
    if !File.exist?(config_file_path)
      abort "Please create a configuration file config/config.yml"
    end

    config = YAML.load_file(config_file_path)
    config = config[rails_env]

    if config.nil?
      abort "The configuration file config/config.yml must contain " \
        "a section for the #{rails_env} environment"
    end

    require_key(config, 'email_from')
    require_key(config, 'github_api_token')
    require_key(config, 'github_webhook_secret')

    config['phusion_github_usernames'] ||= DEFAULT_PHUSION_GITHUB_USERS

    lowercase_phusion_github_usernames(config)

    config
  end

private
  def config_file_path
    File.dirname(__FILE__) + '/../config/config.yml'
  end

  def rails_env
    ENV['RAILS_ENV'] || 'development'
  end

  def require_key(config, key)
    if !config.key?(key)
      abort "The following configuration option in config/config.yml is required: #{key}"
    end
  end

  def lowercase_phusion_github_usernames(config)
    config['phusion_github_usernames_downcased'] =
      config['phusion_github_usernames'].map do |username|
        username.downcase
      end
  end
end
