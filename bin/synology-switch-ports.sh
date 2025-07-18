#! /bin/bash
# Synology does not allow using ports 80 and 443 to other ones.
#
# All credits to https://github.com/SimpleHomelab/Docker-Traefik/blob/master/scripts/ds918/switch_ports.sh.example

# Install: Run this script on boot
# DSM upgrades will reset these changes, which is why we schedule them to happen automatically

DEFAULT_HTTP_PORT=80
DEFAULT_HTTPS_PORT=443
NEW_HTTP_PORT=81
NEW_HTTPS_PORT=444

sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)$DEFAULT_HTTP_PORT\([^0-9]\)/\1$NEW_HTTP_PORT\2/" /usr/syno/share/nginx/*.mustache
sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)$DEFAULT_HTTPS_PORT\([^0-9]\)/\1$NEW_HTTPS_PORT\2/" /usr/syno/share/nginx/*.mustache

synosystemctl restart nginx