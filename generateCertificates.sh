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

# Create directories
echo "Creting directories"
mkdir demoCA && mkdir demoCA/certs && mkdir demoCA/crl && mkdir demoCA/newcerts && mkdir demoCA/private && touch demoCA/index.txt && echo 02 > demoCA/serial

# Move the Self CA certificates
echo "Moving the Self CA certificates"
mv cacert.pem demoCA/ && mv cakey.pem demoCA/private/

# Generate private key pair for the server
echo "Generating private key pair for the server"
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:65537 -out private-key-$domain.pem

# Generate certificate sign request for the server
echo "Generating certificate signing request for the server"
openssl req -new -key private-key-$domain.pem -out cert-req-$domain.csr \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$domain/emailAddress=$email"

# Sign the server certificate
echo "Signing the server certificate"
openssl ca -in cert-req-$domain.csr -out cert-$domain.pem -days 36500 -batch -updatedb

# Rename the Self CA certificate file name:
echo "Renaming Self CA certificate file name"
mv demoCA/cacert.pem demoCA/cert-self-ca.crt

# Check the certificate status
echo "Checking the certificate status"
openssl verify -CAfile demoCA/cert-self-ca.crt cert-$domain.pem

# Install certificates to Apache

#echo "Installing the certificates"
sudo cp cert-$domain.pem /etc/ssl/certs/ && cp demoCA/cert-self-ca.crt /etc/ssl/certs/ && cp private-key-$domain.pem /etc/ssl/private/

out="Protocols h2 http/1.1
<VirtualHost *:443>
        ServerName www.$domain
        SSLEngine on
        SSLCertificateFile "/etc/ssl/certs/cert-$domain.pem"
        SSLCertificateKeyFile "/etc/ssl/private/private-key-$domain.pem"
</VirtualHost>"

# Write the configuration file for SSL
echo "Writing configuration file for SSL"
echo "$out" > /etc/apache2/sites-available/default-ssl.conf

# Enable the configuration
echo "Enabling configuraions"
ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled

# Reload configuration
echo "Reloading server configuration"
sudo systemctl reload apache2