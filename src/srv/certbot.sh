#!/bin/bash

# ------------------------------------------------------------------------------
# Install Let's Encrypt's certbot client.
# ------------------------------------------------------------------------------

apt-get -y install certbot

# By default, Let's Encrypt verifies ownership of domain names by verifying they
# route to the requesting server's IP address. This has some limitations:
#
# - The DNS must already be pointing at the server.
# - The server can't be behind a reverse proxy, eg Cloudflare.
#
# To avoid these limitations Let's Encrypt supports DNS validation as an option.
# It works like this:
#
# - The flag "--preferred-challenge=dns" is provided to the "certbot" program.
# - This returns a random string that must be added as a TXT DNS record.
# - "certbot" is run again and verifies the TXT record exists and is valid.
#
# Some "certbot" plugins exist to automate this process - so it does not need to
# be done manually. These plugisn programmatically addi the DNS record using the
# DNS host's API.
#
# This is Cloudflare's plugin:
# https://certbot-dns-cloudflare.readthedocs.io/en/stable/

apt-get -y install python3-certbot-dns-cloudflare
