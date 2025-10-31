#!/usr/bin/env bash
# shellcheck disable=SC2155

fatal() { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

# FIXME tandoor, pocket-id
target_services=(
  miniflux
)

rustic() { home-server compose tasks/rustic run --rm "$RUSTIC_REPOSITORY" "$@"; }

backup() {
  test -d "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Not a folder or does not exist: $RUSTIC_BACKUP_EXTRA_FILES"
  
  for service in "${target_services[@]}"; do
    echo "Backing up service $service"
    home-server task "$service" backup "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Backup $service failed!"
  done

  echo "--------"
  echo "Backup folder ready for upload: $RUSTIC_BACKUP_EXTRA_FILES'"
  echo "--------"
  echo
  ls -la "$RUSTIC_BACKUP_EXTRA_FILES"
  rustic backup --json
  docker logs "$RUSTIC_REPOSITORY" > /tmp/bananas
  # Fields: .time, .summary.files_new, .summary.files_changed, .summary.total_bytes_processed
  # .summary.backup_duration, .summary.total_duration

  echo "--------"
  echo "Forgetting and pruning data..."
  echo "--------"
  echo
  rustic forget

  echo "--------"
  echo "Checking integrity of the repository..."
  echo "--------"
  echo
  rustic check
 
  echo "--------"
  echo "Checking integrity of the data (higher bandwidth)..."
  echo "--------"
  echo
  
  # To be fine-tuned:
  # - I dont change the data _that_ often.
  # - Backblaze allows up 3 times the average of the data stored as egress.
  # - Backup happens daily.
  # - But..  downloading >1GB per days seem excessive and after a while, this value seems reasonable.
  #rustic check --read-data --read-data-subset=500MB
  #
  rm -r "$RUSTIC_BACKUP_EXTRA_FILES"
}

RUSTIC_REPOSITORY="$1"
shift

export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d --suffix -backup)"
echo "Running rustic for repository: '$RUSTIC_REPOSITORY' and working directory '$RUSTIC_BACKUP_EXTRA_FILES'"

case "${1:-}" in
  backup)   backup                ;;
  rustic)   shift && rustic "$@"  ;;
esac
