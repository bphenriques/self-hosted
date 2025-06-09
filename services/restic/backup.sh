#!/usr/bin/env bash
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH" || exit 2
# shellcheck disable=SC1091
source "${SCRIPT_PATH}/../../../bin/services.sh"

service::bootstrap
service::grant_group_permissions "${RCLONE_CONFIG_DIR}"

# service::compose run -it restic-dropbox /bin/sh

test -n "${BACKUP_DROPBOX_WORKING_DIR}" || error "BACKUP_DROPBOX_WORKING_DIR is not set"
if [ -d "${BACKUP_DROPBOX_WORKING_DIR}" ]; then
  rm -rf "${BACKUP_DROPBOX_WORKING_DIR}"  # This is SUPER SUPER dangerous. mktemp does not work as for some reason, can't export the variable.
fi
mkdir -p "${BACKUP_DROPBOX_WORKING_DIR}"
service::grant_group_permissions "${BACKUP_DROPBOX_WORKING_DIR}"  # Ensure all directories inside can be back up.

../linkding/service.sh  backup "${BACKUP_DROPBOX_WORKING_DIR}" || error "Backup linkding failed!"
../immich/service.sh    backup "${BACKUP_DROPBOX_WORKING_DIR}" || error "Backup immich failed!"
../paperless/service.sh backup "${BACKUP_DROPBOX_WORKING_DIR}" || error "Backup paperless failed!"
../miniflux/service.sh  backup "${BACKUP_DROPBOX_WORKING_DIR}" || error "Backup miniflux failed!"

service::grant_group_permissions "${BACKUP_DROPBOX_WORKING_DIR}" # Set permissions to nested files inside
service::compose run --rm restic-dropbox
