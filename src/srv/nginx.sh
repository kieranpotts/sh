#!/bin/bash

# ------------------------------------------------------------------------------
# Install Nginx.
#
# This script does the following:
#
# - Nginx's default test page is removed.
# - Nginx's default website is disabled (but its config is kept for reference).
# - Nginx's log files are created.
# - Nginx is set to run automatically at system startup.
#
# To test which version of Nginx is installed:
#
#   $ nginx -v
#
# https://www.nginx.com/
# ------------------------------------------------------------------------------

apt-get -y install nginx

rm -rf /var/www/html
rm -f /etc/nginx/sites-enabled/default
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/_example.conf

touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

systemctl start nginx
systemctl enable nginx
