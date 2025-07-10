#!/usr/bin/env bash

case "${1:-}" in
  backup)
    shift
    echo "Backing up gitea to $1"
    test -d "$1" || error "Not a directory or does not exist: $1"
    target_dir="$1"

    docker exec --user git gitea rm -f /app/gitea/gitea-dump.zip
    docker exec --user git gitea /app/gitea/gitea dump --file /app/gitea/gitea-dump.zip
    docker cp gitea:/app/gitea/gitea-dump.zip "$target_dir"/gitea.zip
    ;;
  *)
    echo "Unknown command"
    exit 1
    ;;
esac
