# FIXME

# Rustic

After several iterations, I decided to stick to this iteration:
- Only supports a single repository. Keeps it simpler and avoids leaking credentials between different storage types.
- Cron Jobs in docker and non-root is hard. This can be easily solved using the host's scheduler.

# Reference
- Dropbox: https://nightlies.apache.org/opendal/opendal-docs-release-v0.47.0/docs/services/dropbox/

## Setup

1. Copy one of the service blocks and rename the container and similar fields accordingly.
2. If using `rclone`, ensure you that the backend is set. You can set it locally and then copy to `$HOME/.config/rclone/rclone.conf`.
3. Mount the volumes:
   1. `/data/.cache` where restic stores its cache.
   2. `/config/rclone` the rclone config directory. Must be writable as some backends require writable directory (dropbox).
   3. `/backup-target` that will store the files to backup.
4. Review the environment variables so that it points to the correct location and password (do not commit that!).

## Run

```shell
$ ./service.sh dropbox-backup
```

## Cron

In Synology:
1. User Defined Script
2. As `root` because the script requires changing permissions so that the docker user can write onto some locations (current limitation)
3. Set the desired backup periodicity.
4. Add the following: `HOME_SERVER_ENV=synology /volume1/homes/Bruno-Admin/home-server/synology/services/restic/service.sh dropbox-backup`

## Test

1. Retrieve a copy of the backup: `rclone copyto dropbox:integration-test /tmp/dropbox-integration-test-backup`
2. Restore: `restic -r /tmp/dropbox-integration-test-backup restore latest --target /tmp/restore-work`
3. Let's list it:
```shell
$ tree /tmp//restore-work/
/tmp//restore-work/
└── backup-target
    └── docker-build-restic
        ├── backup.sh
        ├── entrypoint.sh
        └── health.sh
```
