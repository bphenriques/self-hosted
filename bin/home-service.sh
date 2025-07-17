#!/usr/bin/env bash

# Some folders are version controlled and everytime we check-out permissions might be lost. Let's fix that.
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
RESET_GROUP_FILES="config public"
HOME_SERVER_COMPOSE_BIN="${HOME_SERVER_COMPOSE_BIN:-"docker compose"}"
HOME_SERVER_CONFIG_DIR="${HOME_SERVER_CONFIG_DIR:-$XDG_CONFIG_HOME/home-server}"

info()    { printf '[ .. ] %s\n' "$1"; }
success() { printf '[ OK ] %s\n' "$1"; }
warn()    { printf '[ WARN ] %s\n' "$1"; }
fatal()   { printf '[FAIL] %s\n' "$1" 1>&2; exit 1; }
debug() { [ "$DEBUG" = "1" ] && printf '[DEBG] %s\n' "$*"; }

__service::source() {
  local env_file="$1"
  test -f "$env_file" || fatal "The env file $env_file does not exist!"

  debug "Sourcing $env_file"
  set -o allexport
  # shellcheck disable=SC1090
  source "$env_file"
  set +o allexport
}

# In order for chgrp to work, the user that runs this command must share the same group as the user that runs the container.
service::grant_group_permissions() {
  target="$1"

  chmod -R g+rwx "$target"          # r/w for obvious reasons and x to allow cd'ing to the directory if need be (restic example)
  chgrp -R "${PGID}" "$target"
}

# Data directories are exclusively managed by the server and only need to be created once.
# Assumption: any new file created inside will be owned by the user running the container.
# This is required to postgres databases where the owner must match the user running the container.
__service::setup_data_dir() {
  target="$1"
  owner="$2"

  mkdir -p "$target"
  if [ "$(stat -c "%u:%g" "$target")" != "$owner" ]; then
    echo "Data directory '$target' is not owned by $owner (by $(stat -c "%u:%g" "$target")). Using sudo to chown."
    sudo chown -R "$owner" "$target"
  else
    debug "$1 - already has the right owner $owner"
  fi
}

service::setup() {
  export -f debug fatal service::grant_group_permissions __service::setup_data_dir # Expose functions to xargs

  # Assumption: any references within ${DATA_DIR} is a folder. Let's create them and set the owner.
  # shellcheck disable=SC2086
  ! test -d "${DATA_DIR}" && fatal "DATA_DIR is not a directory or does not exist!"
  service::compose config \
    | yq '.services | to_entries | .[] | .value.volumes[] | select(.type == "bind") | .source | select(test(env(DATA_DIR)))' \
    | xargs -I{} sh -c "__service::setup_data_dir \"{}\" $PUID:$PGID"

  # shellcheck disable=SC2086
  for d in $RESET_GROUP_FILES; do
    if [ -d "$d" ]; then
      service::grant_group_permissions "$d"
    fi
  done

  service::create_networks

  # Confirm that all the source volumes exist. Specifically, any volume that can't be automatically created using the above.
  # Docker might create the folders automatically but we want to deal with that manually to ensure permissions are set.
  service::compose config \
    | yq '.services | to_entries | .[] | .value.volumes[] | select(.type == "bind") | .source' \
    | xargs -I{} sh -c 'test -f {} || test -d {} || test -S {} || fatal "The following source under volumes does not exist: {}"'
}

# Order:
# 1. Profile variables: 'default'
# 2. Common variables: .env
# 3. Additional HOME_SERVER_INCLUDE_ENV specified under .env
service::source() {
  __service::source "${HOME_SERVER_CONFIG_DIR}/default.env"

  if [ -f ".env" ]; then
    __service::source .env
  fi

  if ! test -z "${HOME_SERVER_INCLUDE_ENV}"; then
    __service::source "${HOME_SERVER_CONFIG_DIR}/${HOME_SERVER_INCLUDE_ENV}.env"
  fi
}

service::validate() {
  id -u "$PUID" 1> /dev/null || fatal "No such user with id $PUID!"
  grep -qE ":$PGID:" /etc/group || fatal "No such group with id $PGID!"
  id --groups "$UID" | grep -qw "$PGID" >/dev/null || fatal "$UID does not belong to $PGID"
  test -d "${DATA_DIR}" || fatal "DATA_DIR does not exist or is not a directory: $DATA_DIR"

  # Double-checking the setup before doing anything else. This checks both errors and warnings.
  if service::compose config --quiet; then
    # Let's re-run to check for warnings now. This time it may render, so let's render if there are warnings.
    if service::compose config --quiet 2>&1 >/dev/null | grep --quiet "level=warning"; then
      service::compose config
      echo ""
      fatal "The docker compose has some warnings. Please review them before advancing."
    fi
  else
    fatal "The docker compose rendered an invalid config."
  fi
}

service::compose() {
  local compose_args="-f compose.yml"
  if [ -f "compose.$HOME_SERVER_ENV.yml" ]; then
    compose_args="$compose_args -f compose.$HOME_SERVER_ENV.yml"
  fi

  # shellcheck disable=SC2068,SC2086
  $HOME_SERVER_COMPOSE_BIN $compose_args "$@"
}

service::create_network() {
  docker network inspect "$1" >/dev/null 2>&1 || docker network create "$1"
}

service::create_networks() {
  export -f service::create_network
  service::compose config \
    | yq '.networks | to_entries | .[].value | select(.external == true) | .name' \
    | uniq \
    | xargs -I{} bash -c 'service::create_network {}'
}

# Sources the environment
service::bootstrap() {
  service::source
  service::validate
  service::setup

  if [ -f "bootstrap.sh" ]; then
    ./bootstrap.sh || fatal "Failed to run custom bootstrap"
  fi
}

services::list() {
  # shellcheck disable=SC2038
  find services -type f -name "compose.yml" \
    | xargs -I{} dirname {} \
    | xargs -I{} basename {} \
    | uniq
}

shell_completions::bash() {
  local services_list
  #services_list="$(services::list | tr '\n' ' ')"
  echo 'complete -W "compose up down update restart exec create-networks" home-server'
}

! test -n "$HOME_SERVER_ENV" && fatal "HOME_SERVER_ENV not set or is empty: $HOME_SERVER_ENV"
! test -d "$HOME_SERVER_INSTALL_DIR" && fatal "HOME_SERVER_INSTALL_DIR not set or does not exist: $HOME_SERVER_INSTALL_DIR"
! test -d "$HOME_SERVER_CONFIG_DIR" && fatal "HOME_SERVER_CONFIG_DIR not set or does not exist: $HOME_SERVER_CONFIG_DIR"

# export is required so that docker compose can read from it
export HOME_SERVER_SECRETS_DIR="${HOME_SERVER_CONFIG_DIR}/secrets"
! test -d "$HOME_SERVER_SECRETS_DIR" && fatal "HOME_SERVER_SECRETS_DIR not set or does not exist: $HOME_SERVER_SECRETS_DIR"

cd "$HOME_SERVER_INSTALL_DIR" || fatal "failed to go to the root of the home-server project"
case "$1" in
  --list)
    shift
    services::list
    ;;
  --shell-completions)
    shift
    case "$1" in
      bash) shell_completions::bash ;;
      *)  ;;
    esac
    ;;
  repo-update)
    cd "$HOME_SERVER_INSTALL_DIR" || fatal "failed to go to the root of the home-server project"
    info "Fetching Github changes..."
    git fetch
    git rebase "origin/$(git rev-parse --abbrev-ref HEAD)"
    ;;
  create-networks)
    shift
    service="$1"
    cd "services/$service" || fatal "Failed to cd to service directory: $service"
    shift

    service::bootstrap
    service::create_networks
    ;;
  compose)
    shift
    service="$1"
    cd "services/$service" || fatal "Failed to cd to service directory: $service"
    shift

    service::bootstrap
    service::compose "$@"
    ;;
  up)
    shift
    for service in "$@"; do
      info "Downing $service"
      cd "$HOME_SERVER_INSTALL_DIR/services/$service" || fatal "Failed to cd to service directory: $service"
      service::bootstrap
      service::compose up -d
    done
    ;;
  down)
    shift
    for service in "$@"; do
      info "Downing $service"
      cd "$HOME_SERVER_INSTALL_DIR/services/$service" || fatal "Failed to cd to service directory: $service"
      service::bootstrap
      service::compose rm --stop --force
    done
    ;;
  update)
    shift
    for service in "$@"; do
      if grep -q "$service" .home-server-update-ignore; then
        echo "Skipping $service as it is labelled as not to."
      else
        info "Updating $service"
        cd "$HOME_SERVER_INSTALL_DIR/services/$service" || fatal "Failed to cd to service directory: $service"
        info "Updating $service"
        service::bootstrap
        service::compose pull
        if [[ $(service::compose ps | wc -l) -gt 1 ]]; then
          service::compose up -d
        else
          warn "Skipping restart of $service as it is already down."
        fi
      fi
    done
    ;;
  restart)
    shift
    for service in "$@"; do
      info "Restarting $service"
      cd "$HOME_SERVER_INSTALL_DIR/services/$service" || fatal "Failed to cd to service directory: $service"
      service::bootstrap
      service::compose rm --stop --force
      service::compose up -d
    done
    ;;
  jobs)
    shift
    service="$1"
    name="$2"
    shift 2
    cd "$HOME_SERVER_INSTALL_DIR/services/$service" || fatal "Failed to cd to service directory: $service"
    if [ -f "$name.sh" ]; then
      service::source
      bash "./$name.sh" "$@" || fatal "Failed to run '$name' executable under $service"
    else
      info "Skipping as '$name' is not present for $service"
    fi
    ;;
  clean)
    # No warning because I am ok with that. You might not be. Everything running in the server should be tracked to the repo.
    docker system prune -f
    docker image prune -af
    ;;
  *)
    fatal "Unrecognized command $1."
    ;;
esac