#!/bin/bash

# ------------------------------------------------------------------------------
# Install MailDev.
#
# After installation and configuration, MailDev is started and added to PM2's
# list of services to be respawned automatically at machine startup.
#
# https://github.com/maildev/maildev
# ------------------------------------------------------------------------------

# This should already be installed in the default box, but just in case...
sudo npm -g install maildev

# Application server configuration.
sudo touch /etc/nginx/sites-available/${maildev_hostname}.conf
sudo tee /etc/nginx/sites-available/${maildev_hostname}.conf << END

server {
  listen 80;
  listen [::]:80;

  server_name ${maildev_hostname};

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  # Redirect all non-SSL requests to SSL.
  return 301 https://\$host\$request_uri;
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name ${maildev_hostname};

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  ssl_certificate ${sslcert_crt_path};
  ssl_certificate_key ${sslcert_key_path};

  location / {
    proxy_pass http://127.0.0.1:1080;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }

}

END

# Enable this virtual server's configuration.
sudo ln -fs /etc/nginx/sites-available/${maildev_hostname}.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
