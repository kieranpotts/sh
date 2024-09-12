#!/bin/bash

# ------------------------------------------------------------------------------
# Install Redis.
# ------------------------------------------------------------------------------

apt-get -y install redis-server

systemctl enable redis-server
systemctl start redis-server

# https://gist.github.com/kapkaev/4619127
redis-cli config set stop-writes-on-bgsave-error no
