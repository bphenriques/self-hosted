#!/usr/bin/env bash

git pull --rebase origin "$(git rev-parse --abbrev-ref HEAD)"
home-server update --all
