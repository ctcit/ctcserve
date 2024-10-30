#!/bin/bash

echo ">>> Init Letsencrypt $LETSENCRYPT_HOME  $DOMAINS $STAGING"

# Initialise letsencypt
# The certbot command will attempt to obtain a certificate if a valid one is not already present
# The command also installs the certificate by modifying the apache conf
if [ ! -z "$DOMAINS" ]; then
	if (! [ -z "$STAGING" ] ) && [ "$STAGING" != "0" ]; then
	echo "Using Let's Encrypt Staging environment..."
	  certbot -n --staging --expand --authenticator standalone --installer apache --agree-tos --email $WEBMASTER_MAIL --domains $DOMAINS
	else
	  echo "Using Let's Encrypt Production environment..."
	  certbot certonly -n --expand --authenticator standalone --installer apache --agree-tos --email $WEBMASTER_MAIL --domains $DOMAINS
	fi
	sed -i 's/standalone/apache/' /etc/letsencrypt/renewal/*.conf
fi
