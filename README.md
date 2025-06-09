# Home Server

Hi! 

This is how I am currently organizing my self-hosted services running on a Synology DS923+.

> [!IMPORTANT]
> **Disclaimer:** This is my setup that works _for me_. I hope it can be of use to you too.

The guidelines I am trying to follow:
1. **Portability**: I do not want to be tied to a specific vendor, therefore I am using `docker` to run the services.
2. **Security**: **I am no expert**, but I do my best to use the tighten what services have access to (network and/or files).
3. **Testable**: Ability to test locally before deploying.
4. **Backups**: Automated backups.
5. **Infrastructure as code**: _Ideally_, I should be able to spin-up the environments without going through UI settings.

## Installation

Refer to the `README.md` in the correct [environment](./environments).

## Scripts

Example:
- Up: `./bin/home-service.sh up service1 service2`.
- Down: `./bin/home-service.sh down service1 service2`.

It might ask for `sudo` to set the ownership of the docker data directories. This is required to `chown` to the user that actually runs the container. For example, `postgres` does not run without proper ownership.

