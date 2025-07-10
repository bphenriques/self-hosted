# Synology

Non-exhaustive documentation regarding how I am setting up my server.

## Users

| User             | Type          | Extra Groups                                         | Services |
|------------------|---------------|------------------------------------------------------|----------|
| `guest`          | Disabled      | -                                                    | -        |
| `admin`          | Disabled      | -                                                    | -        |
| `Bruno-Admin`    | Admin         | `docker`, `docker-data-private`, `docker-data-media` | All      |
| `Bruno`          | User          | `private`, `media`                                   | Only SMB |
| `docker-media`   | Internal User | `docker-data-media`                                  | None     |
| `docker-private` | Internal User | `docker-data-private`, `docker-data-media`           | None     |

Note: `Bruno-Admin` must share some groups with `docker` and `docker-private` in order to set group permissions correctly to run containers.

## Shared Folders

| Folder        | Storage Type | Recycle Bin | Snapshot | Hidden     | Media | Description                                                           |
|---------------|--------------|-------------|----------|------------|-------|-----------------------------------------------------------------------|
| `bphenriques` | HDD          | Yes         | Yes      | Restricted | No    | Private files.                                                        |
| `docker`      | NvME SSD     | No          | Yes      | Yes        | No    | Docker data files.                                                    |
| `media`       | HDD          | Yes         | Yes      | No         | No    | Media files with no private information.                              |
| `shared`      | HDD          | Restricted  | Yes      | No         | Yes   | Shared files across all users.                                        |
| `homes`       | HDD          | Yes         | Yes      | Yes        | Yes   | Requires enabling under `Uses & Group` -> `Advanced` -> `User Home`.. |

## Groups

| Group                 | Docker Data | Private Media | Media | Description                                                                              |
|-----------------------|-------------|---------------|-------|------------------------------------------------------------------------------------------|
| `docker`              | No          | No            | No    | Group to call `docker` without `sudo`. I am still running `docker` in a root context.    |
| `docker-data-media`   | Yes         | No            | Yes   | R+W permissions to docker data directory and media files that do not handle private data |
| `docker-data-private` | Yes         | Yes           | Yes   | R+W permissions to docker data directory  and media files that handle private data       |
| `private`             | No          | Yes           | No    | R+W permissions to private media files.                                                  |
| `media`               | No          | No            | Yes   | R+W permissions to non-private media files.                                              |

## Snapshots

Under Snapshot Replication application, I setup the snapshot service per folder. For example:
- Every 2h at midnight.
- Retain all snapshots for 5 days.
- Retain the latest snapshot per day for 60 days.

And also enable the tickbox that makes the snapshots visible.

## Cron Jobs

- Default cron jobs that checks the disks (quick and extended SMART tests).
- Daily cronjob that empties the recycle bins.
- Weekly script that updates the server (this requires setting up a renovate token):
```
source /var/services/homes/Bruno-Admin/.bashrc
/volume1/homes/Bruno-Admin/home-server/bin/check-updates.sh
/volume1/homes/Bruno-Admin/home-server/bin/update.sh
```

## SSH

1. Enable SSH and change port
2. Under `Users and Group` and then `advanced`, enable home directory. There should be two new folders: `home` and `homes`.
3. SSH to your machine: `ssh Bruno-Admin@{ip or host}`
4. Edit `/etc/ssh/sshd_config`: `sudo vim etc/ssh/sshd_config`:
   1. `#PubkeyAuthentication yes` is not commented
   2. `#AuthorizedKeysFile  .ssh/authorized_keys` is not commented
5. Restart SSH: `sudo synoservicectl --reload sshd`.
6. Sign-off of your NAS SSH session and run: `ssh-copy-id -p <port> Bruno-Admin@{ip or host}` to copy our public key.

TODO: ideally disable password authentication (see [this link](https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/)) and rely solely on SSH keys.

## Docker

1. Grant `Bruno-Admin` permissions to run `docker` commands by setting the group of the socket: `sudo chown root:docker /var/run/docker.sock`

Notes/Gotchas:
1. Using volume bindings rather than named volumes. Named volumes are problematic with postgres as they fail due to permissions. Probably because I am setting `user` (tried `:z` with no success)
2. If the user has multiple groups and access to a file is tied to a specific group, then that group must be used (can't pass multiple groups).
3. Version controlled files lose permissions therefore, they might need to be remedied from time to time.

## Firewall

TODO. Likely need to allow any internal ip and deny any other ip. I will only manage my ip from my local network.

## Basic Setup
1. Setup https://github.com/007revad/Synology_HDD_db if you haven't.
2. Install Git and Container Manager in your Synology page.

## Home Server Setup

Setup Github authentication using a SSH key:
1. Install Git in the NAS using the native package manager.
2. SSH to the NAS.
3. Create an SSH key: `ssh-keygen -t ed25519 -C "4727729+bphenriques@users.noreply.github.com`
4. Go to https://github.com/settings/ssh/new and add the public key generated.
5. If you have issues with permissions, set the key's permissions to 600.

Following this and in a SSH session:
1. Clone the repo: `git clone git@github.com:bphenriques/home-server.git`.
2. Create the configuration files and run the basic setup:
```shell
$ mkdir -p .config/home-server
$ cd home-server
$ environments/synology.setup.sh
```
3. Outside the session, copy the `environments/synolog/*.env` to `.config/home-server` files and adjust them particularly:
```
HOME_SERVER_CNAME=my-url
HOME_SERVER_BASE_URL=my-url:port
```

I suggest https://www.duckdns.org/ as it is and is good enough. Synology reserves the HTTP/HTTPS ports, therefore I also
recommend using a different port such as `8443` for HTTPS (there is a way to use `443` but I am avoiding as it is a bit
intrusive for my liking).

Finally:
1. Depending on the service, you will likely need to copy secrets to `$HOME/.config/home-server/secrets`.
2. Follow the instructions on the `README.md` on how to run the services.

## Tailscale

I use Tailscale as it is directly supported, albeit I will consider setting up a separate headless server just for Wireguard.

1. Follow the Synology instructions: https://tailscale.com/kb/1131/synology
2. Add the `192.168.1.192/32` subnet so that only that IP is exposed. The same IP is being pointed by my DuckDNS account.
3. Enable Exit Node so that all traffic goes through my NAS. Also enable exit node local network access.
4. Approve the requests in the admin console.
5. Enable device approval.
6. Disable SSH access. I rather have that disabled and it likely won't work as my servers use a different default port.

## Misc

- Disable automatically power on when the power is restored.
