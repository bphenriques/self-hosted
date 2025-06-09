#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH/../.." || exit 2

rustic_dropbox() { bin/home-service.sh compose rustic run --rm rustic-dropbox "$@"; }

# TODO: git, hoarder, kitchenowl,
prepare() {
  mkdir -p "$1"/test
  echo "Backing up hello"
  echo "Hello" > "$1"/test/file.txt
  #home-server backup "$1" || error "Backup linkding failed!"
  #home-server backup "$1" || error "Backup miniflux failed!"
}

case "${1:-}" in
  init)
    rustic_dropbox init
    ;;
  backup)
    shift
    target="$(mktemp -d --suffix -dropbox-backup)"
    prepare "$target"

    export RUSTIC_BACKUP_EXTRA_FILES="${target}"
    rustic_dropbox backup
    rustic_dropbox forget
    rustic_dropbox prune
    rustic_dropbox check
    ;;
  ls)
    shift
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic_dropbox ls latest
    ;;
  restore)
    shift
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic_dropbox restore latest "$1"
    ;;
esac