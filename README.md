This server is being archived as I am moving to a [NixOS based installation](https://github.com/bphenriques/dotfiles).

This repository is still relevant if you have a Docker based solution.

---

# Home Server

Hi! 

This is how I am currently self-hosting services on a Synology DS923+ (my first NAS/server).

> [!IMPORTANT]
> **Disclaimer:** This is my setup that works _for me_. I hope it helps you too.

The guidelines I am trying to follow:
1. **Security**: I am not an expert, but I do my best.
2. **3-2-1 Backups**: to physical external drive, and encrypted to the cloud ([backblaze](https://www.backblaze.com/)).
3. **Reproducible**: _For the most part_ the services should run locally.

# Stack

- **DNS registration**: [Cloudflare](./infrastructure/cloudflare.md).
- **Reverse proxy**: [`traefik`](https://github.com/traefik/traefik).
- **Authentication / Authorization**: [`pocket-id`](https://github.com/pocket-id/pocket-id) as OIDC provider for the apps that support it.
- **Remote access**: Tailscale. There are other options but this was seamless.

## How to

Example of commands available once installed:
```shell
$ home-server up --all
$ home-server update service
```

**Note**: during the first time, it might ask for `sudo` to set the docker data directories with the right ownership.

## Testing

Requirements:
- [`yq`](https://github.com/mikefarah/yq)
- Docker with `root` ([rootless `docker`](https://docs.docker.com/engine/security/rootless/) is hit-and-miss for me).
- Docker compose.

1. Add a `.env.local`:
    ```shell
    export HOME_SERVER_ACME_EMAIL=...
    export HOME_SERVER_CNAME=...
    ```
2. Set `DNS-01 Challenge` (see [cloudflare docs](./infrastructure/cloudflare.md)).
3. Depending on the service, copy and adapt the example secret/environment files.
4. We should be good to go:
    ```shell
    $ ./bin/local.sh up traefik
    ```
   
5. Create the user in [`pocket-id`](https://pocket-id.MYDOMAIN/signup/setup).
6. Depending on the service, register the client in `pocket-id`.
