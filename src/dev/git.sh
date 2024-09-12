#!/bin/bash

# ------------------------------------------------------------------------------
# Install and configure Git.
#
# To view Git's configuration:
#
#   $ git config --list
#
# https://git-scm.com/
# ------------------------------------------------------------------------------

apt-get -y install git

[ ! -z "${git_user_name}" ] && git config --global user.name "${git_user_name}"
[ ! -z "${git_user_email}" ] && git config --global user.email "${git_user_email}"
