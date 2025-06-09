#!/usr/bin/env bash
# https://miniflux.app/docs/api.html#endpoint-export

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH" || exit 2

test -d "$1" || error "Not a directory or does not exist: $1"
target_dir="$1/miniflux"
echo "Backing up miniflux: ${target_dir}"
mkdir -p "${target_dir}"

bin/home-service.sh compose miniflux exec miniflux \
  /bin/sh -c 'wget -qO- -S "http://${ADMIN_USERNAME}:${ADMIN_PASSWORD}@localhost:8080/v1/export"'