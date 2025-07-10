#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH/../.." || exit 2

rustic_dropbox() { bin/home-service.sh compose rustic run --rm rustic-dropbox "$@"; }

# TODO: gitea
prepare() {
  mkdir -p "$1"/test
  echo "Backing up hello"
  echo "Hello" > "$1"/test/file.txt
  home-server exec gitea backup "$1" || error "Backup gitea failed!"
  home-server exec linkding backup "$1" || error "Backup linkding failed!"
  #home-server backup miniflux "$1" || error "Backup miniflux failed!"

  # TODO: chmod everything inside $1
}

# photos
# gitea

case "${1:-}" in
  init)
    rustic_dropbox init
    ;;
  backup)
    shift
    target="$(mktemp -d --suffix -dropbox-backup)"
    prepare "$target"

    export RUSTIC_BACKUP_EXTRA_FILES="${target}"

    echo "Backup folder ready for upload: $target"

    #rustic_dropbox backup
    #rustic_dropbox forget
    #rustic_dropbox prune
    #rustic_dropbox check
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