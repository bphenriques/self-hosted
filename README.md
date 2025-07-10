# Home Server

Hi! 

This is how I am currently organizing my self-hosted services running on a Synology DS923+.

> [!IMPORTANT]
> **Disclaimer:** This is my setup that works _for me_. I hope it can be of use to you too.

The guidelines I am trying to follow:
1. **Portability**: I do not want to be tied to a specific vendor, therefore I am using `docker` to run the services.
2. **Security**: **I am no expert**, but I do my best.
3. **Backups**: Automated backups.
4. **Reproducible**: _Tentatively_, I should be able to spin-up the environments without going through user interfaces.

See [docs](./docs) for more information.

## Usage

Example of commands available once installed:
```shell
$ home-server up service
$ home-server update service2
```

**Note**: during the first time, it might ask for `sudo` to set the ownership of the docker data directories as expected by the container.

## Running locally

Requirements:
- `yq` from https://github.com/mikefarah/yq
- Docker with `root` ([rootless `docker`](https://docs.docker.com/engine/security/rootless/) is hit-and-miss for me).
- Docker compose.

```shell
$ source .env.local
$ mkdir /tmp/home-server
$ ./bin/home-service.sh up memos
```

Note: I could have made the script more generic but opting out for now.
