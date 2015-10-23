require 'yaml'

class ConfigFileLoader
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

    config
  end

private
  def config_file_path
    File.dirname(__FILE__) + '/../config/config.yml'
  end

  def rails_env
    ENV['RAILS_ENV'] || 'development'
  end
end
