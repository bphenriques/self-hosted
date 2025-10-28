#!/usr/bin/env bash

# renovate/renovate:41.144
RENOVATE_VERSION="sha256:6fdc3d455dfbf656a34861121fff41cdcfce92b95afbc77524a5f6b071fd3032"

test -z "${RENOVATE_TOKEN}" && echo "RENOVATE_TOKEN is not set!" && exit 1

git pull --rebase origin "$(git rev-parse --abbrev-ref HEAD)"

docker run --rm -e RENOVATE_TOKEN="${RENOVATE_TOKEN}" \
  "renovate/renovate@${RENOVATE_VERSION}" \
  bphenriques/self-hosted --onboarding false
