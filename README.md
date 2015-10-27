# Support Central

Easily manage community and commercial support! Support Central is an aggregator for various support channels. It displays in a central interface which support tickets need replying on.

The following support channels are currently supported:

 * Github issue tracker
 * Supportbee

## Installation guide

This app requires PostgreSQL.

 1. Install Ruby 2.2.
 2. [Install Nginx + Passenger](https://wwww.phusionpassenger.com/).
 3. Create a user `support_central`:

        $ sudo adduser support_central
        $ sudo passwd support_central

 4. Clone this repository to '/var/www/support_central':

        $ sudo mkdir /var/www/support_central
        $ sudo chown support_central: /var/www/support_central
        $ sudo -u support_central -H git clone git://github.com/phusion/support_central /var/www/support_central
        $ cd /var/www/support_central

 5. Open a shell as `support_central`. If you are using RVM:

        $ rvmsudo -u support_central -H bash
        $ export RAILS_ENV=production

    If you are not using RVM:

        $ sudo -u support_central -H bash
        $ export RAILS_ENV=production

 6. Create a database, edit database configuration:

        $ cp config/database.yml.example config/database.yml
        $ editor config/database.yml

 7. Install the gem bundle:

        $ bundle install --without development test --production

 8. Run database migrations, generate assets:

        $ bundle exec rake db:migrate assets:precompile RAILS_ENV=production

 9. Create an initial set of users:

        $ bundle exec rake db:seed RAILS_ENV=production

 10. Generate a secret key:

        $ bundle rake secret RAILS_ENV=production

     Take note of the output. You need it in the next step.

 11. Add Nginx virtual host. Be sure to substitute the `passenger_env_var` values with appropriate values.

        server {
            listen 443;
            server_name www.yourhost.com;
            ssl_certificate ...;
            ssl_certificate_key ...;
            ssl on;
            root /var/www/support_central/public;
            passenger_enabled on;

            # Fill in an appropriate value for email 'From' fields.
            passenger_env_var MAILER_SENDER yourapp@yourdomain.com;
            # Fill in the root URL of the app.
            passenger_env_var ROOT_URL https://www.yourhost.com;
            # Fill in value of secret key you generated in step 10.
            passenger_env_var SECRET_KEY_BASE ...;
        }
