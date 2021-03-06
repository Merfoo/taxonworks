#! /bin/bash

# Fail after the first non zero
set -e 

cd /app

bundle exec erb /app/config/docker/nginx/webapp.conf.erb  > /etc/nginx/sites-enabled/webapp.conf
bundle exec erb /app/config/docker/nginx/secret_key.conf.erb  > /etc/nginx/main.d/secret_key.conf 

bundle exec erb /app/config/docker/secrets.yml.erb > /app/config/secrets.yml
bundle exec erb /app/config/docker/database.yml.erb > /app/config/database.yml
bundle exec erb /app/config/docker/application_settings.yml.erb > /app/config/application_settings.yml

bundle exec rake assets:precompile 

bundle exec erb /app/config/docker/pgpass.erb > /root/.pgpass
chmod 0600 /root/.pgpass
bundle exec rake tw:production:deploy:update_database database_user=$POSTGRES_USER database_host=$TAXONWORKS_DB_PORT_5432_TCP_ADDR 
