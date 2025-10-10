#!/usr/bin/env bash
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -ef
cd "$SCRIPT_PATH"/.. || exit 2

# renovate/renovate:41.144
RENOVATE_VERSION="sha256:6fdc3d455dfbf656a34861121fff41cdcfce92b95afbc77524a5f6b071fd3032"

test -z "${RENOVATE_TOKEN}" && echo "RENOVATE_TOKEN is not set!" && exit 1

docker run --rm \-e RENOVATE_TOKEN="${RENOVATE_TOKEN}" "renovate/renovate:${RENOVATE_VERSION}" bphenriques/self-hosted --onboarding false
