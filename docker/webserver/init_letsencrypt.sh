#!/bin/bash

echo ">>> Init Letsencrypt $LETSENCRYPT_HOME  $DOMAINS $STAGING"

cert_dir="$LETSENCRYPT_HOME/live/ctc.org.nz"
cert_file="$cert_dir/fullchain.pem"
key_file="$cert_dir/privkey.pem"

# Reuse an existing certificate when one is already present.
if [ -f "$cert_file" ] && [ -f "$key_file" ]; then
	echo "Using existing certificate at $cert_dir"
elif [ ! -z "$DOMAINS" ] && [ "$LETSENCRYPT_ENABLE" = "1" ]; then
	# Initialise letsencypt
	# The certbot command will attempt to obtain a certificate if a valid one is not already present
	# The command also installs the certificate by modifying the apache conf
	if [ ! -z "$STAGING" ] && [ "$STAGING" != "0" ]; then
		echo "Using Let's Encrypt Staging environment..."
		certbot -n --staging --expand --authenticator standalone --installer apache --agree-tos --email "$WEBMASTER_MAIL" --domains "$DOMAINS"
	else
		echo "Using Let's Encrypt Production environment..."
		certbot certonly -n --expand --authenticator standalone --installer apache --agree-tos --email "$WEBMASTER_MAIL" --domains "$DOMAINS"
	fi
	sed -i 's/standalone/apache/' /etc/letsencrypt/renewal/*.conf
else
	echo "Generating local self-signed certificate for Apache"
	mkdir -p "$cert_dir"
	openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
		-subj "/CN=ctc.org.nz" \
		-keyout "$key_file" \
		-out "$cert_file"
fi
