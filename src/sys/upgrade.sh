#!/bin/bash

# ------------------------------------------------------------------------------
# Upgrade to the latest packages, without requiring user interaction.
#
# https://serverfault.com/a/839563
# https://askubuntu.com/a/147079
# ------------------------------------------------------------------------------

# Install available upgrades to all existing packages ("upgrade").
DEBIAN_FRONTEND=noninteractive apt-get --yes --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Upgrade current operating system version ("dist-upgrade").
DEBIAN_FRONTEND=noninteractive apt-get --yes --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
