server "support_central@internal.phusion.nl", :roles => [:app, :web, :db]

set :rvm_ruby_version, '2.3.4'
set :repo_url, 'git://github.com/phusion/support_central.git'
set :ssh_options, forward_agent: true
set :passenger_environment_variables, { :path => '/opt/production/passenger-enterprise/bin:$PATH' }
set :passenger_restart_command, '/opt/production/passenger-enterprise/bin/passenger-config restart-app'
set :passenger_restart_with_sudo, false
