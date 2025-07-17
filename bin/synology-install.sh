#!/usr/bin/env bash
set -ef

# shellcheck disable=SC2155
readonly PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."

# XDG_USR_BIN is not a standard variable, only the path is: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
readonly XDG_USR_BIN="${HOME}/.local/bin"
readonly XDG_DATA_HOME="${HOME}/.local/share"

readonly DOCKER_COMPOSE_VERSION=2.30.3
readonly YQ_VERSION=4.40.5
readonly SYNOLOGY_HDD_DB_VERSION=3.6.111

basic_git() {
  git config --global pull.rebase true
}

# shellcheck disable=SC1091
setup_paths() {
  mkdir -p "$XDG_USR_BIN"
  if [[ ":$PATH:" != *":$XDG_USR_BIN:"* ]]; then
    echo "Adding $XDG_USR_BIN to PATH at the start"
    echo "export PATH=\"$XDG_USR_BIN:\${PATH}\"" >> "${HOME}/.bashrc"
    source "${HOME}/.bashrc"
  fi

  mkdir -p "$XDG_DATA_HOME"
}

# Reason: Synology's version is way too old. E.g., does not support multiple --env-file (introduced in 2.17). Synology ships with v2.9.0-6413-g38f6ac.
install_docker_compose() {
  if [ ! -f "$XDG_USR_BIN/docker-compose" ]; then
    echo "Installing docker-compose $DOCKER_COMPOSE_VERSION"
    curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64" -o "$XDG_USR_BIN/docker-compose"
    chmod +x "$XDG_USR_BIN/docker-compose"
  fi
}

install_yq() {
  if [ ! -f "$XDG_USR_BIN/yq" ]; then
    echo "Installing yq $YQ_VERSION"
    curl -L "https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_amd64" -o "$XDG_USR_BIN/yq"
    chmod +x "$XDG_USR_BIN/yq"
  fi
}

install_synology_hdd_db() {
  if [ ! -d "$XDG_DATA_HOME/synology_hdd_db" ]; then
    echo "Installing Synology_hdd_db $SYNOLOGY_HDD_DB_VERSION"
    curl -L "https://github.com/007revad/Synology_HDD_db/archive/refs/tags/v$SYNOLOGY_HDD_DB_VERSION.tar.gz" | tar -xz --directory "$XDG_DATA_HOME"
    mv "$XDG_DATA_HOME/Synology_HDD_db-$SYNOLOGY_HDD_DB_VERSION" "$XDG_DATA_HOME/synology_hdd_db"
    chmod +x "$XDG_DATA_HOME/synology_hdd_db/syno_hdd_db.sh"
    echo
    echo "Warning: Ensure to add a cron-job that runs $XDG_DATA_HOME/synology_hdd_db/syno_hdd_db.sh -nr on every boot by root"
  fi
}

# shellcheck disable=SC2016,SC1091
base_setup() {
  if [ -z "$XDG_CONFIG_HOME" ]; then
    echo 'export XDG_CONFIG_HOME="$HOME"/.config' >> "${HOME}/.bashrc"
    source "${HOME}/.bashrc"
  fi
}

# shellcheck disable=SC1091,SC2016
setup_home_server_env() {
  mkdir -p "$HOME/.config/home-server/secrets"
  if [ -z "$HOME_SERVER_ENV" ]; then
    {
      echo 'export HOME_SERVER_ENV=prod'
      echo 'export HOME_SERVER_INSTALL_DIR="$HOME/home-server"'
      echo 'export HOME_SERVER_COMPOSE_BIN="docker-compose"' # FIXME: remove this once Synology ships with a docker compose version > v2.30.3
      echo 'eval "$($HOME/home-server/bin/home-service.sh --shell-completions bash)"'

    } >> "${HOME}/.bashrc"
    source "${HOME}/.bashrc"
  fi

  if [ ! -f "$XDG_USR_BIN/home-server" ]; then
    echo "Installing home-server"
    ln -s "${PROJECT_ROOT}/bin/home-service.sh" "$XDG_USR_BIN/home-server"
    chmod +x "$XDG_USR_BIN/home-server"
  fi
}

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this command as root!"
  exit 1
fi

basic_git
base_setup

setup_paths
install_docker_compose
install_yq
install_synology_hdd_db

setup_home_server_env
