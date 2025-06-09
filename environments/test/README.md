What you need:
- `yq` from https://github.com/mikefarah/yq
- Docker with `root` ([Rootless `docker`](https://docs.docker.com/engine/security/rootless/) is hit-and-miss for me).
- Docker Compose.

In this environment, services will expose a port around `3000`. I might consider making it more similar to the real
environment by setting up a revert-proxy locally.