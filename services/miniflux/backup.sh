#!/usr/bin/env bash
# https://miniflux.app/docs/api.html#endpoint-export

test -d "$1" || error "Not a directory or does not exist: $1"
target_dir="$1"
echo "Backing up miniflux: ${target_dir}"
mkdir -p "${target_dir}"

home-server compose miniflux exec miniflux \
  /bin/sh -c 'wget -qO- -S "http://${ADMIN_USERNAME}:${ADMIN_PASSWORD}@localhost:8080/v1/export"' \
  > "${target_dir}"/miniflux.opml
