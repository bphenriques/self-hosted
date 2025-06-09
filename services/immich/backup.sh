#!/usr/bin/env bash


# TODO: FAIL IF no arguments
# TODO: FAIL IF no arguments
# # TODO: FAIL IF no arguments


# https://immich.app/docs/administration/backup-and-restore
test -d "$1" || error "Not a directory or does not exist: $1"
docker container inspect immich_postgres > /dev/null 2>&1 || error "Container immich_postgres does not exist"

target_dir="$1/immich"
echo "Backing up immich: ${target_dir}"
mkdir "${target_dir}"
source .env
docker exec -t immich_postgres pg_dumpall -c -U "$DB_USERNAME" | gzip > "${target_dir}/dump.sql.gz"
echo '
docker compose create                                                                                 # Create Docker containers for without running them.
docker start immich_postgres                                                                          # Only startt PSQL server
sleep 10                                                                                              # Wait for Postgres server to start up
gunzip < "/path/to/backup/dump.sql.gz" | docker exec -i immich_postgres psql -U postgres -d immich    # Restore Backup
' > "${target_dir}/restore.sh"

echo 'Follow the restore.sh script carefully. In short, from a clean-slate spin up the DB, seed and then boot the remaining containers' > "${target_dir}/restore.md"