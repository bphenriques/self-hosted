#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH/../.." || exit 2

rustic() { bin/home-service.sh compose rustic run --rm rustic-dropbox "$@"; }

prepare() {
  home-server job backup gitea "$1" || error "Backup gitea failed!"
  home-server job backup linkding "$1" || error "Backup linkding failed!"
  home-server job backup miniflux "$1" || error "Backup miniflux failed!"
  # FIXME: tandoor

  echo "Fixing permissions to $PUID:$PGID"
  sudo chmod -R g+rwx "$target"         # r/w for obvious reasons and x to allow cd'ing to the directory
  sudo chown -R "$PUID:$PGID" "$1"      # Ensure it is not set to root.
}

case "${1:-}" in
  init)
    rustic init
    ;;
  backup)
    shift
    target="$(mktemp -d --suffix -dropbox-backup)"
    prepare "$target"

    export RUSTIC_BACKUP_EXTRA_FILES="${target}"

    echo "Backup folder ready for upload: $target"

    #rustic backup
    #rustic forget
    #rustic prune
    #rustic check
    ;;
  ls)
    shift
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic ls latest
    ;;
  restore)
    shift
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic restore latest "$1"
    ;;
esac