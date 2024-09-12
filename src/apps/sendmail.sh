#!/bin/bash

# ------------------------------------------------------------------------------
# Install Sendmail.
# ------------------------------------------------------------------------------

apt-get install -y sendmail

systemctl enable sendmail
systemctl start sendmail
