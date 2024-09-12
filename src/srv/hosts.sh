#!/bin/bash

# ------------------------------------------------------------------------------
# Edit the "/etc/hosts" file.
#
# This is required by some CLI tools, such as cURL, to make requests back to the
# local application.
# ------------------------------------------------------------------------------

sudo tee /etc/hosts << END
127.0.0.1 localhost
127.0.0.1 ${application_hostname}
127.0.0.1 ${maildev_hostname}
END
