#!/usr/bin/env bash

fatal() { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

test ! -f .env.local && fatal ".env.local does not exist"

source .env.local
export HOME_SERVER_INSTALL_DIR="$(pwd)"
export HOME_SERVER_CONFIG_DIR="${HOME_SERVER_INSTALL_DIR}/infrastructure/environments/local"
export HOME_SERVER_ENV=local
export HOME_SERVER_BASE_URL="${HOME_SERVER_CNAME}:8443"

mkdir -p /tmp/home-server

# FIXME: hooks?
mkdir -p /tmp/home-server/traefik/letsencrypt
touch /tmp/home-server/traefik/letsencrypt/acme.json
chmod 0600 /tmp/home-server/traefik/letsencrypt/acme.json

./bin/home-service.sh "$@"


