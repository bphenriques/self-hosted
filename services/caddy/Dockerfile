# See https://hub.docker.com/_/caddy
FROM caddy:2.10-builder AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/mholt/caddy-webdav

FROM caddy:2.10
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
