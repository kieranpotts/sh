#!/bin/bash

# ------------------------------------------------------------------------------
# SSH hardening.
#
# https://www.ssh.com/ssh/sshd_config
# ------------------------------------------------------------------------------

tee /etc/ssh/sshd_config << END

# Change the SSH port from the default port 22.
Port ${ssh_port}

# Use SSHD protocol version 2.
Protocol 2

# Encryption keys for protocol version 2.
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Turn on privilege separation for security.
UsePrivilegeSeparation yes

# Lifetime and size of ephemeral version 1 server key.
KeyRegenerationInterval 3600
ServerKeyBits 1024

# Logging format and verbosity.
SyslogFacility AUTH
LogLevel INFO

# Disconnect after 30 seconds if the user fails to provide a valid password.
# (Dedefault = 120)
LoginGraceTime 30

# The maximum number of authentication attempts allowed per connection.
MaxAuthTries 3

# The maximum number of open shell, login or subsystem (e.g. SFTP) sessions
# permitted per network connection.
MaxSessions 2

# Disallow the default "root" user from logging in over SSH.
PermitRootLogin no

# Ensure SSH files and directories have proper permissions and
# ownerships before starting a new SSH session.
StrictModes yes

# Enable public key authentication.
RSAAuthentication yes
PubkeyAuthentication yes

# Don't read the user's ~/.rhosts or ~/.shosts files in HostbasedAuthentication.
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

# Never allow empty passwords.
PermitEmptyPasswords no

# Disable challenge-response passwords.
ChallengeResponseAuthentication no

# Disable clear-text password authentication.
PasswordAuthentication no

# Permit X11 forwarding.
X11Forwarding yes
X11DisplayOffset 10

# When a user logs in interactively, disable printing of /etc/motd, and do print
# the date and time of the last login.
PrintMotd no
PrintLastLog yes

# Ensure that broken connections are properly noticed and handled.
TCPKeepAlive yes

# Allow clients to pass locale environment variables.
AcceptEnv LANG LC_*

# Define subsystems.
Subsystem  sftp  /usr/lib/openssh/sftp-server

# Enables the Pluggable Authentication Module interface.
UsePAM yes

END

# Restart the "ssh" service.
/etc/init.d/ssh restart
