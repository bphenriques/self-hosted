#!/usr/bin/env bash

# FIXME it has to be shutdown during

# https://github.com/sissbruecker/linkding/blob/master/docs/backup.md#database
test -d "$1" || error "Not a directory or does not exist: $1"

docker exec --user git gitea /app/gitea/gitea dump --file /app/gitea/gitea-dump.zip
docker exec --user git gitea rm -f /app/gitea/gitea-dump.zip
docker cp gitea:/app/gitea/gitea-dump.zip "$1"/gitea.zip