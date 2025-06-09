#!/usr/bin/env bash
set -ef

# shellcheck disable=SC2155
readonly PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."

"$PROJECT_ROOT"/bin/home-service.sh repo-update
# shellcheck disable=SC2043,SC2038
for service_path in $(find services -type f -name "compose.yml" | xargs dirname | uniq); do
  cd "$PROJECT_ROOT/$service_path"
  "$PROJECT_ROOT"/bin/home-service.sh update "$(basename "$service_path")"
done
