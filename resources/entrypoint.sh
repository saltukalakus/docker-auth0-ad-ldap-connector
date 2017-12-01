#!/bin/bash
set -e

if [ ! -f ./config.json ]; then
  echo "Required config.json file not found. Please mount it. For example:"
  echo "-v /path-to-this-project/config.json:/opt/auth0-adldap/config.json"
  exit 1
fi

# the admin server uses port 8357
node admin/server.js &

# health checker uses port 8080 ...
# used by Docker HEALTHCHECK but can also be used by load balancer (e.g. AWS ELB)
node healthcheck.js &

# wait a moment to get messages from the other apps out the way
sleep 1

# start the connector
node server.js