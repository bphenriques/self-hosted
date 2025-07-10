#!/usr/bin/env bash
set -ef

chgrp 65541 Caddyfile.prod
chmod g+r Caddyfile.prod