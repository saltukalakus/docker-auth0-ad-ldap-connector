#!/bin/bash
set -e

APP_DIR="/opt/auth0-adldap"
CERT_DIR="/opt/auth0-adldap/certs"
CERT="$CERT_DIR/cert"

if [ ! -f ./config.json ]; then
  echo "Required config.json file not found. Please mount it. For example:"
  echo "-v /path-to-this-project/config.json:/opt/auth0-adldap/config.json"
  exit 1
fi

# certs
if [ -s "$CERT.key" ] || [ -s "$CERT.pem" ] ; then
    echo "Using existing certificate"
else
    echo "Generating self-signed certificate in INSIDE the container."
    echo "This actually won't work if the TICKET URL was already used before."
    echo "It's fine for testing, but you really should map to an existing cert."
    cd "$CERT_DIR"
	openssl req -x509 -new -nodes -newkey rsa:2048 -keyout cert.key -out cert.crt -subj "/C=ZZ/ST=Bliss/L=Local/O=None/OU=DevOps/CN=example.com"
	cat ./cert.crt ./cert.key > ./cert.pem
	cd "$APP_DIR"
fi

# the admin server uses port 8357
node admin/server.js &

# wait a moment to get messages from admin/server.js out the way
sleep 1

# start the connector
node server.js