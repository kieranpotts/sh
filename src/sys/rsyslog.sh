#!/bin/bash

# ------------------------------------------------------------------------------
# Configure rsyslog.
#
# With this configuration, cron events will be logged to "/var/log/cron.log" not
# the default "/var/log/syslog".
#
# https://www.rsyslog.com/
# ------------------------------------------------------------------------------

tee /etc/rsyslog.d/100-cron.conf << END
cron.* /var/log/cron.log
END

# Restart "rsyslog" and "cron" services.
service rsyslog restart
service cron restart
