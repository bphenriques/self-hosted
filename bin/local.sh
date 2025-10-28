#!/usr/bin/env bash
#shellcheck disable=SC2155,SC1091

fatal() { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

test ! -f .env.local && fatal ".env.local does not exist"

source .env.local
export HOME_SERVER_INSTALL_DIR="$(pwd)"
export HOME_SERVER_CONFIG_DIR="${HOME_SERVER_INSTALL_DIR}/infrastructure/environments/local"
export HOME_SERVER_ENV=local
export HOME_SERVER_BASE_URL="${HOME_SERVER_CNAME}"

mkdir -p "/tmp/home-server"

./bin/home-service.sh "$@"


