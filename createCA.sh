#!/bin/bash

# Required
domain=vccw.test
commonname=coderman

# Optional
country=DE
state=Berlin
locality=Berlin
organization=coderman
organizationalunit=IT
email=admin@coderman.codes

# Generate certificate key pair for the Self CA
echo "Creating key pair for Self CA"
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:65537 -out cakey.pem

# Self sign certificate with 100 years of validity
echo "Signing the self generated certificate"
openssl req -new -x509 -key cakey.pem -out cacert.pem -days 36500 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

# Rename the Self CA certificate file name:
echo "Renaming Self CA certificate file name"
mv cacert.pem cert-self-ca.crt
