#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash restic rclone
# shellcheck shell=bash
# shellcheck disable=SC1091

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH" || exit 2
# shellcheck disable=SC1091
source "${SCRIPT_PATH}/../../../bin/services.sh"

fatal() {
  # shellcheck disable=SC2059
  printf '[FATAL] %s\n' "$1" 1>&2 # Redirect to stderror
  exit 1
}

backup_services=(
  immich
  linkding
  paperless
  miniflux
)

# shellcheck disable=SC2068
for d in ${backup_services[@]}; do
  "../$d/"/service.sh up -d
done

echo "Running backup"
# FIXME
exit 0
./service.sh dropbox-backup

restore_dir="$(mktemp -d --suffix "_restic_test")"
mkdir "$restore_dir/encrypted"
mkdir "$restore_dir/decrypted"

echo "Copying remote folder locally to $restore_dir/encrypted"
rclone copyto dropbox:integration-test "$restore_dir/encrypted"

echo "Restoring backup to $restore_dir/decrypted"
source secrets.env.example
export RESTIC_PASSWORD="$RESTIC_PASSWORD"
restic -r "$restore_dir/encrypted" restore latest --target "$restore_dir/decrypted"

test -d "$restore_dir/decrypted/backup-target/documents"          || fatal "Documents were not backup!"
test -d "$restore_dir/decrypted/backup-target/docker/immich"      || fatal "Immich wasn't backup!"
test -d "$restore_dir/decrypted/backup-target/docker/paperless"   || fatal "paperless wasn't backup!"
test -d "$restore_dir/decrypted/backup-target/docker/miniflux"    || fatal "miniflux wasn't backup!"
test -d "$restore_dir/decrypted/backup-target/docker/linkding"    || fatal "linkding wasn't backup!"
