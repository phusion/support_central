# Contributing to Support Central

## Howto

To contribute to Support Central, write some code and send a pull request. Please follow these guidelines:

 1. Use clear commit messages. The intent of the commit must be clear, as well as the problem and the solution.
 2. Make sure that you have tests.

## Setting up a development environment

Support Central is written in Rails 4 and uses RSpec for tests. It requires PostgreSQL, even in development.

 1. Create configuration files:

     * config/database.yml
     * config/secrets.yml
     * config/config.yml

 2. Install dependencies: `bundle install`
 3. Load the database schema: `bundle exec rake db:schema:load`
 4. Create an initial set of users: `bundle exec rake db:seed`
 5. Start a development server: `passenger start`

You can now login with any of the email addresses created by `rake db:seed`. The development password is 12345678.
