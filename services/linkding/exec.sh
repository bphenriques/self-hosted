#!/usr/bin/env bash

case "${1:-}" in
  backup)
    shift
    # https://github.com/sissbruecker/linkding/blob/master/docs/backup.md#database
    echo "Backing up linkding to $1"
    test -d "$1" || error "Not a directory or does not exist: $1"
    target_dir="$1/linkding"

    echo "Backing up linkding: ${target_dir}"
    mkdir "${target_dir}"
    docker exec -t linkding rm /etc/linkding/data/backup.sqlite3
    docker exec -t linkding python manage.py backup /etc/linkding/data/backup.sqlite3
    docker cp linkding:/etc/linkding/data/backup.sqlite3 "${target_dir}/backup.sqlite3"
    # FIXME: restore instructions
    ;;
  *)
    echo "Unknown command"
    exit 1
    ;;
esac

