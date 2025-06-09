#!/usr/bin/env bash
# shellcheck disable=SC2155
readonly PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."

find "$PROJECT_ROOT" -type f -name "*.sh" -exec shellcheck "{}" \;
