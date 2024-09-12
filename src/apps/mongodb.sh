#!/bin/bash

# ------------------------------------------------------------------------------
# Install MongoDB.
#
# https://www.mongodb.com/
# ------------------------------------------------------------------------------

apt-get -y install mongodb

# Bind "mongos" and "mongod" to listen to localhost for client connections.
# service mongodb stop
# sed -i 's/bindIp\: 127\.0\.0\.1/bindIp\: 0\.0\.0\.0/' /etc/mongodb.conf
# service mongodb start
