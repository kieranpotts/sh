#!/bin/bash

# ------------------------------------------------------------------------------
# Create a Unix user for the system administrator.
#
# This user has "sudo" privileges. A public key must be provided to authenticate
# over SSH.
# ------------------------------------------------------------------------------

adduser --disabled-password --force-badname --gecos "" ${adm_user}
echo ${adm_user}:${adm_pswd} | /usr/sbin/chpasswd

# Add to "sudo" group.
usermod -aG sudo ${adm_user}

# Add to the www-data group.
usermod -aG www-data ${adm_user}

# Add the administrator's authorized public key for SSH access.
mkdir -p /home/${adm_user}/.ssh
touch /home/${adm_user}/.ssh/authorized_keys
echo ${adm_authorized_key} > /home/${adm_user}/.ssh/authorized_keys

# Set appropriate permissions on the authorized_keys file.
chmod 700 /home/${adm_user}/.ssh
chmod 600 /home/${adm_user}/.ssh/authorized_keys
chown -R ${adm_user}:${adm_user} /home/${adm_user}/.ssh

# Install a local public/private key pair for the adm_* user.
echo "${adm_private_key}" > /home/${adm_user}/.ssh/id_rsa
echo "${adm_public_key}" > /home/${adm_user}/.ssh/id_rsa.pub

# Set appropriate permissions on the public/private key files.
chmod 600 /home/${adm_user}/.ssh/id_rsa
chown ${adm_user}:${adm_user} /home/${adm_user}/.ssh/id_rsa
chown ${adm_user}:${adm_user} /home/${adm_user}/.ssh/id_rsa.pub

# Add the private key to the SSH agent.
eval "$(ssh-agent -s)"
ssh-add /home/${adm_user}/.ssh/id_rsa

# Fix "EACCES permission denied" `scandir` error on some `yarn` commands.
mkdir /home/${adm_user}/.config
chown -R ${adm_user}:${adm_user} /home/${adm_user}/.config
