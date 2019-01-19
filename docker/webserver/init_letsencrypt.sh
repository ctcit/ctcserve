#!/bin/bash

echo "Init Letsencrypt $LETSENCRYPT_HOME  $DOMAINS $STAGING"

# init only if lets-encrypt is running for the first time and if DOMAINS was set
if ([ ! -d $LETSENCRYPT_HOME/live ] || [ ! "$(ls -A $LETSENCRYPT_HOME)" ]) && [ ! -z "$DOMAINS" ]; then
	if (! [ -z "$STAGING" ] ) && [ "$STAGING" != "0"]; then
	  echo "Using Let's Encrypt Staging environment..."
	  certbot -n --staging --expand --authenticator standalone --installer apache --agree-tos --email $WEBMASTER_MAIL --domains $DOMAINS
	else
	  echo "Using Let's Encrypt Production environment..."
	  certbot -n --expand --authenticator standalone --installer apache --agree-tos --email $WEBMASTER_MAIL --domains $DOMAINS
	fi
	sed -i .bak 's/standalone/apache/' /etc/letsencrypt/renewals/*.conf
fi
