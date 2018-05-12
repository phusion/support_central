# Contributing to Support Central

## Howto

To contribute to Support Central, write some code and send a pull request. Please follow these guidelines:
 1. Fork the repo 
 2. Create a branch 
 3. Use clear commit messages. The intent of the commit must be clear, as well as the problem and the solution.
 4. Make sure that you have tests.
 5. Open a Pull Request

## Setting up a development environment

Support Central is written in Rails 5 and uses RSpec for tests. It requires PostgreSQL, even in development.

 1. Create configuration files:

     * config/database.yml
     * config/secrets.yml
     * config/config.yml
     
 2. Install dependencies: `bundle install`
 3. Create database: `bundle exec rails db:create`
 4. Load the database schema: `bundle exec rails db:schema:load`
 5. Create an initial set of users: `bundle exec rails db:seed`
 6. Start a development server: `rails start` or `passenger start` :-)

You can now login with any of the email addresses created by `rake db:seed`. The development password is 12345678.

