#!/usr/bin/env bash
# shellcheck disable=SC2155

# FIXME tandoor, pocket-id
target_services=(
  miniflux
)

rustic() { home-server compose tasks/rustic run --rm "$RUSTIC_REPOSITORY" "$@"; }

init() {
  export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
  rustic init
}

backup() {
  target="$(mktemp -d --suffix -backup)"
  for service in "${target_services[@]}"; do
    home-server tasks "$service" backup "$target" || error "Backup $service failed!"
  done

  echo "Fixing permissions to $PUID:$PGID"
  ls -la "$target"
  sudo chmod -R g+rwx "$target"         # r/w for obvious reasons and x to allow cd'ing to the directory
  sudo chown -R "$PUID:$PGID" "$target"      # Ensure it is not set to root.
  ls -la "$target"
  echo "Backup folder ready for upload: $target"

  export RUSTIC_BACKUP_EXTRA_FILES="${target}"
  rustic backup
  rustic forget
  rustic check
}

list_snapshots() {
  export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
  rustic ls latest
}

restore_snapshot() {
  local snapshot="$1"
  export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d)" # doesnt matter
  rustic restore latest "$snapshot"
}

RUSTIC_REPOSITORY="$1"
shift
services::source
case "${1:-}" in
  init)     init                  ;;
  backup)   backup                ;;
  ls)       list_snapshots        ;;
  restore)  restore_snapshot "$2" ;;
esac
