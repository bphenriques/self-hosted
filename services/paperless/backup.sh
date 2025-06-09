#!/usr/bin/env bash
# https://docs.paperless-ngx.com/administration/#exporter

fatal()   { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }

test -d "$1" || fatal "Not a directory or does not exist: $1"
target_dir="$1/paperless"

echo "Backing up paperless: ${target_dir}"
mkdir "${target_dir}"

docker exec -t paperless document_exporter ../export --delete --no-archive --no-thumbnail --use-folder-prefix
docker exec -t -u 0 paperless chown "$PUID:$PGID" /usr/src/paperless/export
docker cp paperless:/usr/src/paperless/export "${target_dir}"

# shellcheck disable=SC2016
echo 'Restore instructions:
1. Shutdown paperless
2. Bind the exported backup to `/usr/src/paperless/export`
3. Start paperless
4. Run `docker exec paperless document_importer ../export`
' >> "${target_dir}/restore.md"
# Note: intentionally not deleting the backup files inside the container.

bootstrap() {
  service::source default private
  case $HOME_SERVER_ENV in
    "local")    service::source secrets.env.example                          ;;
    "synology") service::source "${HOME_SERVER_SECRETS_DIR}/paperless.env"   ;;
  esac

  service::validate
  service::setup
}

service::main "$@"
