#!/bin/bash

# ------------------------------------------------------------------------------
# Install and configure Monit.
#
# Monit is an open source program for managing and monitoring Unix processes. It
# provides a web interface for easy remote interaction.
#
# https://mmonit.com/monit/
# ------------------------------------------------------------------------------

apt-get install -y monit

systemctl start monit.service
systemctl enable monit.service

# Allow access to Monit's web interface from any IP address but secure it with a
# strong password.
tee /etc/monit/conf.d/auth << END
set httpd port ${monit_port} and
  allow 0.0.0.0/0.0.0.0
  allow ${monit_user}:${monit_pswd}
END

# IMPORTANT: This script must be run only _after_ the following programs — which
# are monitored by Monit — are installed.

# Monitor and control MySQL.
tee /etc/monit/conf.d/mysql << END
check process mysqld with pidfile /var/run/mysqld/mysqld.pid
  start program = "/etc/init.d/mysql start"
  stop program = "/etc/init.d/mysql stop"
END

# Monitor and control Nginx.
tee /etc/monit/conf.d/nginx << END
check process nginx with pidfile /var/run/nginx.pid
  start program = "/etc/init.d/nginx start"
  stop program = "/etc/init.d/nginx stop"
END

monit -t
monit reload
monit start all
