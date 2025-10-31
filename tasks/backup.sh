#!/usr/bin/env bash
# shellcheck disable=SC2155

fatal() { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

# FIXME tandoor, pocket-id
target_services=(
  # miniflux
)

rustic() { home-server compose tasks/rustic run --rm "$RUSTIC_REPOSITORY" "$@"; }

backup_summary() {
  jq -c '.summary | "Backup took \(.total_duration) seconds (A: \(.files_new) M: \(.files_changed)). Size: \(.total_bytes_processed) bytes."'
}

backup() {
  test -d "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Not a folder or does not exist: $RUSTIC_BACKUP_EXTRA_FILES"
  
  for service in "${target_services[@]}"; do
    echo "Backing up service $service"
    home-server task "$service" backup "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Backup $service failed!"
  done

  local output     
  output="$(rustic backup --json | jq -rc '.')"
  echo "$output" | backup_summary

  printf "\nForgetting and prunning data"
  rustic forget

  printf "\nChecking repository integrity"
  rustic check

  printf "\nChecking repository and data integrity"

  # 500MB offers a good balance given the write frequency and the backup periodicity.
  rustic check --read-data --read-data-subset=500MB  

  rm -r "$RUSTIC_BACKUP_EXTRA_FILES"
}

RUSTIC_REPOSITORY="$1"
shift

export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d --suffix -backup)"
echo "Running rustic for repository: '$RUSTIC_REPOSITORY' and working directory '$RUSTIC_BACKUP_EXTRA_FILES'"

case "${1:-}" in
  backup)   shift && backup "$@"  ;;
  rustic)   shift && rustic "$@"  ;;
esac
