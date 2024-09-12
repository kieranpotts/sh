#!/bin/bash

# ------------------------------------------------------------------------------
# Install Node.js.
#
# To check installed versions.
#
#   $ nodejs -v
#   $ npm -v
#
# https://nodejs.org/en/
# ------------------------------------------------------------------------------

# This will install the v14.x LTS release of Node.js from the NodeSource package
# archives. https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
apt-get install -y nodejs

# From local development boxes we should not do SSL key validation in requesting
# resources from the NPM registry over HTTPS - else "npm update" will return the
# error code "UNABLE_TO_GET_ISSUER_CERT_LOCALLY".  The "strict-ssl=false" option
# is set at the global level.
# https://github.com/npm/npm/issues/9580#issuecomment-288937937
mkdir /usr/etc
tee /usr/etc/npmrc << END
strict-ssl=false
END
