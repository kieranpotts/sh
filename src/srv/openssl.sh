#!/bin/bash

# ------------------------------------------------------------------------------
# Generate self-signed SSL certificates to be shared by all applications.
# ------------------------------------------------------------------------------

sslcert_cnf_path="/etc/ssl/certs/${sslcert_file_name}.cnf"
sslcert_key_path="/etc/ssl/certs/${sslcert_file_name}.key"
sslcert_csr_path="/etc/ssl/certs/${sslcert_file_name}.csr"
sslcert_crt_path="/etc/ssl/certs/${sslcert_file_name}.crt"

# Self-signed wildcard SSL certificate configuration.
#
# The main common name is included in subjectAltName not only commonName, due to
# Chrome removing the ability to identify the host using only commonName - since
# Chrome v58. https://stackoverflow.com/a/42917227
echo "
[ req ]
default_bits       = 4096
default_md         = sha512
prompt             = no
encrypt_key        = no
distinguished_name = dn
req_extensions     = ext

[ dn ]
countryName            = "ME"
localityName           = "Bywater"                # L=
organizationName       = "The Green Dragon"       # O=
organizationalUnitName = "Kitchen"                # OU=
commonName             = "${sslcert_common_name}" # CN=

[ ext ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.0 = ${sslcert_common_name}
DNS.1 = ${sslcert_alt_name_1}
DNS.2 = ${sslcert_alt_name_2}
DNS.3 = ${sslcert_alt_name_3}
" | sudo tee ${sslcert_cnf_path}

# Generate key.
sudo su -c "openssl genrsa -out ${sslcert_key_path} 2048" &> /dev/null # Noisy!

# Create the certificate signing request (CSR).
sudo su -c "openssl req -new -out ${sslcert_csr_path} \
  -key ${sslcert_key_path} \
  -config ${sslcert_cnf_path}" &> /dev/null # A bit noisy!

# Sign the SSL certificate.
sudo su -c "openssl x509 -req -days 3650 -in ${sslcert_csr_path} \
  -signkey ${sslcert_key_path} \
  -out ${sslcert_crt_path} \
  -extensions ext -extfile ${sslcert_cnf_path}" &> /dev/null # A bit noisy!
