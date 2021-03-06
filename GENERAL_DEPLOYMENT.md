# Deploying to production

This app requires PostgreSQL.

 1. Install Ruby > 2.2. (setup is tested up to Ruby 2.5 and Rails 5.0)
 2. [Install Nginx + Passenger](https://wwww.phusionpassenger.com/).
 3. Create a user `support_central`:

        $ sudo adduser support_central
        $ sudo passwd support_central

 4. Clone this repository to '/var/www/support_central':

        $ sudo mkdir /var/www/support_central
        $ sudo chown support_central: /var/www/support_central
        $ sudo -u support_central -H git clone git://github.com/phusion/support_central.git /var/www/support_central
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
        $ chmod 600 config/database.yml

 7. Edit general configuration:

        $ cp config/config.yml.example config/config.yml
        $ editor config/config.yml
        $ chmod 600 config/config.yml

 8. Install the gem bundle:

        $ bundle install --without development test --deployment

 9. Run database migrations, generate assets:

        $ bundle exec rake db:migrate assets:precompile RAILS_ENV=production

 10. Create an initial set of users:

        $ bundle exec rake db:seed RAILS_ENV=production

 11. Generate a secret key:

        $ bundle rake secret RAILS_ENV=production

     Take note of the output. Create a secrets.yml and put the output in there as instructed:

        $ cp config/secrets.yml.example config/secrets.yml
        $ editor config/secrets.yml
        $ chmod 600 config/secrets.yml

 12. Add Nginx virtual host. Be sure to substitute the `passenger_env_var` values with appropriate values.

        server {
            listen 443;
            server_name www.yourhost.com;
            ssl_certificate ...;
            ssl_certificate_key ...;
            ssl on;
            root /var/www/support_central/public;
            passenger_enabled on;
        }

13. Connect your support channels. 
![Support Central](https://phusion.github.io/support_central/img/supportcentral.png)

14. Marvel at the beauty of it all. 

_This guide is for non-Phusion employees. If you are a Phusion employee, please read the [Phusion employee deployment guide.](PHUSION_DEPLOYMENT.md)_
