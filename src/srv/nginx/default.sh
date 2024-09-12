#!/bin/bash

# ------------------------------------------------------------------------------
# Configure a default Nginx server.
# ------------------------------------------------------------------------------

default_nginx_conf=/etc/nginx/sites-available/default.conf

touch ${default_nginx_conf}
tee ${default_nginx_conf} << END

# Catch all requests to any other hostnames that may be pointing at this server,
# and redirect them to the main application. This makes it possible to configure
# hostname aliases at the DNS level. Example: if the FQDN "example.com" resolves
# to this server and the main hosted applicated is configured to respond to that
# server name, then to have "www.example.com" automatically redirect, all you do
# is point that hostname at the same server via your DNS.
#
# Note - for this to work fully, all alias hostnames must be included in the SSL
# certificate for the main application.

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;

  server_name _;

  ssl_certificate /etc/letsencrypt/live/${application_hostname}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${application_hostname}/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/${application_hostname}/fullchain.pem;

  return 301 https://${application_hostname}\$request_uri;
}

END

# Enable the server configuration.
ln -s ${default_nginx_conf} /etc/nginx/sites-enabled/

# Check for syntax errors in the Nginx config and attempt reload.
nginx -t
systemctl reload nginx
