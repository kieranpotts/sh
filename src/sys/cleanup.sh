#!/bin/bash

# ------------------------------------------------------------------------------
# Clean up disk space.
# ------------------------------------------------------------------------------

# Remove package dependencies that are no longer required.
apt-get -y autoremove

# Remove APT cache.
apt-get -y clean
