#!/usr/bin/env bash

# https://github.com/sissbruecker/linkding/blob/master/docs/backup.md#database
echo "Backing up linkding to $1"
test -d "$1" || error "Not a directory or does not exist: $1"
target_dir="$1"

echo "Backing up linkding: ${target_dir}"
docker exec -t linkding rm /etc/linkding/data/backup.sqlite3
docker exec -it linkding python manage.py full_backup /etc/linkding/data/backup.zip
docker cp linkding:/etc/linkding/data/backup.zip "${target_dir}/linkding.zip"
# FIXME: restore instructions
