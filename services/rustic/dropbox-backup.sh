#!/usr/bin/env bash
# shellcheck disable=SC2155

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH/../.." || exit 2

# Enough space to hold a full-extra backup.
MIN_AVAILABLE=5000000000

target_services=(
  gitea
  linkding
  miniflux
  # FIXME: tandoor
  #
)

rustic() { bin/home-service.sh compose rustic run --rm rustic-dropbox "$@"; }

dropbox_available_space() {
  response="$(curl -X POST https://api.dropboxapi.com/2/users/get_space_usage -H "Authorization: Bearer $HOME_SERVER_DROPBOX_ACCESS_TOKEN" | jq -cr)"

  total="$(echo "$response" | jq -r '.allocation.allocated')"
  used="$(echo "$response" | jq -r '.used')"
  echo "$total $used" | awk '{print ($1-$2)}'
}

prepare() {
  if [ "$(dropbox_available_space)" -lt $MIN_AVAILABLE ]; then
    echo "Not enough space in Dropbox. Aborting"
    return 1
  fi

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
    rustic init
    ;;
  backup)
    shift
    target="$(mktemp -d --suffix -dropbox-backup)"
    prepare "$target"

    export RUSTIC_BACKUP_EXTRA_FILES="${target}"
    rustic backup
    rustic forget
    rustic prune
    rustic check
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