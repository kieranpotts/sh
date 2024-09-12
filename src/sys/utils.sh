#!/bin/bash

# ------------------------------------------------------------------------------
# Install useful system utilities.
#
# "build-essential" is a single reference to all the packages you need to make a
# Debian package. It includes the gcc/g++ compilers plus other utilities.
# https://packages.ubuntu.com/bionic/build-essential
#
# "software-properties-common" is a reference to the repositories and tools from
# which we install common software.
# https://packages.ubuntu.com/bionic/software-properties-common
#
# Other useful  system utilities include Python's package manager ("pip"), Curl,
# OpenSSL, and "zip"/"unzip".
#
# https://curl.haxx.se/
# https://www.openssl.org/
# https://docs.python.org/3/installing/index.html
# https://packages.ubuntu.com/bionic/libssl-dev
# https://packages.ubuntu.com/bionic/zip
# https://packages.ubuntu.com/bionic/unzip
# ------------------------------------------------------------------------------

apt-get -y install build-essential
apt-get -y install software-properties-common

apt-get -y install curl
apt-get -y install openssl libssl-dev
apt-get -y install python3-pip
apt-get -y install zip unzip
