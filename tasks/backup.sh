#!/usr/bin/env bash
# shellcheck disable=SC2155

fatal() { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

# FIXME tandoor, pocket-id
target_services=(
  # miniflux
)

target_repositories=(
  bphenriques/self-hosted
  bphenriques/dotfiles
  bphenriques/dotfiles-private
  bphenriques/curriculum-vitae
  bphenriques/retro-handhelds
)

rustic() { home-server compose tasks/rustic run --rm "$RUSTIC_REPOSITORY" "$@"; }

backup_repositories() {
  test -z "${GITHUB_BACKUP_TOKEN}" && fatal "GITHUB_BACKUP_TOKEN is not set!"

  mkdir -f "$RUSTIC_BACKUP_EXTRA_FILES"/github
  for repo in "${target_repositories[@]}"; do
    echo "Backing up $repo"
    curl -H "Authorization: Bearer ${GITHUB_BACKUP_TOKEN}" -L "https://api.github.com/repos/$repo/tarball" \
      > "$RUSTIC_BACKUP_EXTRA_FILES/github/$repo.tar.gz"
  done
}

backup_summary() {
  jq -c '.summary | "Backup complete in \(.total_duration) seconds (A:\(.files_new) M:\(.files_changed) S:\(.total_bytes_processed) bytes)."'
}

backup() {
  test -d "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Not a folder or does not exist: $RUSTIC_BACKUP_EXTRA_FILES"
  test -z "${GITHUB_BACKUP_TOKEN}" && echo "GITHUB_BACKUP_TOKEN is not set!" && exit 1

  for service in "${target_services[@]}"; do
    echo "Backing up service $service"
    home-server task "$service" backup "$RUSTIC_BACKUP_EXTRA_FILES" || fatal "Backup $service failed!"
  done
  backup_repositories

  local output     
  output="$(rustic backup --json | jq -rc '.')"
  echo "$output" | backup_summary

  printf "\nForgetting and prunning data\n"
  rustic forget

  printf "\nChecking repository integrity\n"
  rustic check

  printf "\nChecking repository and data integrity\n"

  # 500MB offers a good balance given the write frequency and the backup periodicity.
  rustic check --read-data --read-data-subset=500MB  

  rm -r "$RUSTIC_BACKUP_EXTRA_FILES"
}

RUSTIC_REPOSITORY="$1"
shift

export RUSTIC_BACKUP_EXTRA_FILES="$(mktemp -d --suffix -backup)"
echo "Running rustic for repository: '$RUSTIC_REPOSITORY' and working directory '$RUSTIC_BACKUP_EXTRA_FILES'"

case "${1:-}" in
  backup)   backup ;;
  rustic)   shift && rustic "$@"  ;;
esac
