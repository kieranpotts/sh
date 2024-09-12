#!/bin/bash

# ------------------------------------------------------------------------------
# Install Fail2Ban.
#
# Fail2Ban provides protection against brute-force SSH attacks. It automatically
# blacklists clients by their IP address, stopping them logging in to the server
# after too many failed attempts.
#
# It works by monitoring system logs - looking for symptoms of automated attacks
# based on rules that the system administrator configures. It will automatically
# add new rules to "iptables", blocking the IP addresses of suspected attackers,
# either for a limited amount of time or permanently.
#
# Fail2Ban can be used to monitor other protocols including HTTP and SMTP but it
# is primarily focused on providing protection against SSH attacks.
#
# The file "jail.conf" in "/etc/fail2ban/" sets the rules for detecting attacks.
# It also determines the jail terms of banned clients. The default configuration
# can be modified by adding a file called "jail.local".
#
# The main options to pay attention to are "maxretry", "findtime" and "bantime":
#
# - "maxretry" limits how many failed login attempts can be made from any one IP
#   address before that address is blacklisted.
# - "findtime" determines the number of seconds in which "maxtries" are allowed.
# - "bantime" sets the length of time in seconds for which an IP address remains
#   blacklisted. A negative number makes the ban permanent.
#
# Fail2Ban can send email alerts when an attack is suspected:
#
# - "destemail" is the email address to delivery notifications to.
# - "sender" is the value of the "from" field.
#
# The "action" setting defines what actions occur when a client is banned:
#
# - "%(action_)s" just bans the client.
# - "%(action_mw)s" bans the client and sends an email with a WHOIS report.
# - "%(action_mwl)s" bans the client and sends an email with a WHOIS report plus
#   all relevant lines from the log file.
# ------------------------------------------------------------------------------

apt-get install -y fail2ban

echo '' > /etc/fail2ban/jail.local

tee /etc/fail2ban/jail.local << END
backend = systemd

maxretry = 3     # If three failed attempts...
findtime = 3600  # ... within one hour...
bantime = 86400  # ... ban the user for one day.

destemail = ${adm_email}
sender = ${adm_email}

action = %(action_mw)s

END

systemctl enable fail2ban
systemctl start fail2ban
