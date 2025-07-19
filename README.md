# Home Server

Hi! 

This is how I am currently organizing my self-hosted services running on a Synology DS923+ (my first setup).

> [!IMPORTANT]
> **Disclaimer:** This is my setup that works _for me_. I hope it can be of use to you too.

The guidelines I am trying to follow:
1. **Portability**: I do not want to be tied to a specific vendor, therefore I am using `docker` to run the services.
2. **Security**: **I am no expert**, but I do my best.
3. **Backups**: Automated backups.
4. **Reproducible**: _Tentatively_, I should be able to spin-up the environments without going through user interfaces. Ideally I would use terraform, but.. the benefits do not outweigh the time I have available.

# Stack

- **DNS registration**: [Cloudflare](./infrastructure/cloudflare.md).
- **Reverse proxy**: [`traefik`](https://github.com/traefik/traefik).
- **Authentication / Authorization**: [`pocket-id`](https://github.com/pocket-id/pocket-id) as OIDC provider for the apps that support it natively, and [`traefik-oidc-auth`](https://github.com/sevensolutions/traefik-oidc-auth) as proxy for the services that don't.
- **Remote access**: Tailscale. There are other options but this was seamless on Synology.

# Requirements

Tied to what I currently own:
- Domain registered in Cloudflare
- Tailscale account

I am running on a Synology NAS but it is not a requirement as everything runs on top of docker.

## Usage

Example of commands available once installed:
```shell
$ home-server up service
$ home-server update service2
```

**Note**: during the first time, it might ask for `sudo` to set the ownership of the docker data directories as expected by the container.

## Testing

Requirements:
- `yq` from https://github.com/mikefarah/yq
- Docker with `root` ([rootless `docker`](https://docs.docker.com/engine/security/rootless/) is hit-and-miss for me).
- Docker compose.

1. Add a `.env.local`:
    ```shell
    export HOME_SERVER_ACME_EMAIL=...
    export HOME_SERVER_CNAME=...
    ```
2. I am using Traefik as reverse proxy, let's set `DNS-01 Challenge`. Check [cloudflare docs](./infrastructure/cloudflare.md).
3. Depending on what you are using, you might need to copy and adapt the example secret/environment files.
4. We should be good to go:
    ```shell
    $ ./bin/local.sh up traefik
    ```
   

## Acknowledments
