#!/usr/bin/env bash
# shellcheck disable=SC2155

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH/../.." || exit 2

# FIXME tandoor
target_services=(
  miniflux
)

rustic() { bin/home-service.sh compose backup-blaze run --rm backup-blaze "$@"; }

prepare() {
  for service in "${target_services[@]}"; do
    home-server jobs "$service" backup "$1" || error "Backup $service failed!"
  done

  echo "Fixing permissions to $PUID:$PGID"
  sudo chmod -R g+rwx "$target"         # r/w for obvious reasons and x to allow cd'ing to the directory
  sudo chown -R "$PUID:$PGID" "$1"      # Ensure it is not set to root.

  echo "Backup folder ready for upload: $target"
}

case "${1:-}" in
  init)
    shift
    export RUSTIC_BACKUP_EXTRA_FILES="${target}"
    rustic init
    ;;
  backup)
    shift
    target="$(mktemp -d --suffix -backup)"
    prepare "$target"

    export RUSTIC_BACKUP_EXTRA_FILES="${target}"
    rustic backup
    rustic forget
    rustic check
    ;;
  ls)
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic ls latest
    ;;
  restore)
    export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
    rustic restore latest "$2"
    ;;
esac
