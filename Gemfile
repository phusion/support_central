source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 2.6.1', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.20'

gem 'pg'
gem 'devise'
gem 'octokit'
gem 'supportbee', git: 'https://github.com/phusion/supportbee'
gem 'frontapp', git: 'https://github.com/phusion/frontapp'

gem 'net-http-persistent', '~> 4.0'
gem 'default_value_for'
gem 'concurrent-ruby'
gem 'rest-client'
gem 'acts_as_list'
gem 'schema_associations'
# gem 'schema_auto_foreign_keys'
gem 'schema_plus_foreign_keys', git: 'https://github.com/phusion/schema_plus_foreign_keys'
gem 'schema_validations'

group :development do
  gem 'annotate'
  gem 'spring-commands-rspec'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'rbnacl-libsodium'
  gem 'rbnacl', '>= 3.2', '< 5.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'

  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 4.2'
  gem 'web-console'
  gem 'listen', '~> 3.8.0'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails'
  gem 'awesome_print'
end

group :test do
  gem 'test-unit'
  gem 'webmock'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

group :development, :ci do
  gem 'bundler-audit'
end
