#!/usr/bin/env bash

if ! test -d "${DATA_DIR}"; then
  echo "DATA_DIR does not exist or it is not a directory: $DATA_DIR"
  exit 1
fi

if ! test -d "${DATA_DIR}/traefik/letsencrypt"; then
  sudo mkdir -p "${DATA_DIR}/traefik/letsencrypt"
  sudo touch "${DATA_DIR}"/traefik/letsencrypt/acme.json
fi

if [ "$(stat -c "%a" "${DATA_DIR}"/traefik/letsencrypt/acme.json)" != "600" ]; then
  echo "The permissions to acme.json are too broad. Restricting to 0600"
  sudo chmod 0600 "${DATA_DIR}"/traefik/letsencrypt/acme.json
fi
