#!/usr/bin/env bash
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH"/.. || exit 2

test -z "${RENOVATE_TOKEN}" && echo "RENOVATE_TOKEN is not set!" && exit 1

docker run --rm -e RENOVATE_TOKEN="${RENOVATE_TOKEN}" renovate/renovate:38 bphenriques/home-server --onboarding false
