#!/usr/bin/env bash
# https://miniflux.app/docs/api.html#endpoint-export

case "${1:-}" in
  backup)
    shift
    test -d "$1" || error "Not a directory or does not exist: $1"
    target_dir="$1/miniflux"
    echo "Backing up miniflux: ${target_dir}"
    mkdir -p "${target_dir}"

    home-server compose miniflux exec miniflux /bin/sh -c 'wget -qO- -S "http://${ADMIN_USERNAME}:${ADMIN_PASSWORD}@localhost:8080/v1/export"'
    ;;
  *)
    echo "Unknown command"
    exit 1
    ;;
esac
