#!/bin/bash

# ------------------------------------------------------------------------------
# Install UFW.
#
# UFW - Uncomplicated Firewall - is a program for managing a netfilter firewall.
# It is designed to be easy to use.
#
# To review the current firewall rules:
#
#   $ ufw status verbose
# ------------------------------------------------------------------------------

apt-get install -y ufw

systemctl start ufw
systemctl enable ufw

# Enable logging, with low levels of verbosity.
ufw logging on low

# Default policies: deny all incoming traffic, allow all outgoing.
ufw default deny incoming
ufw default allow outgoing

# Allow HTTP and HTTPS connections.
ufw allow 80
ufw allow 443

# Allow connections on other ports as required.
for port in "${allowed_ports[@]}"; do
	ufw allow ${port}
done

# Enable the rules.
echo "y" | ufw enable
