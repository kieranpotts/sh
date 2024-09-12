#!/bin/bash

# ------------------------------------------------------------------------------
# System updates.
# ------------------------------------------------------------------------------

# Clean up any failed packages, cached from previous builds.
apt-get -y autoremove
apt-get --purge remove && apt-get autoclean

# Fetch latest updates for all pre-installed software.
apt-get update
