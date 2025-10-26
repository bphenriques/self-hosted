# Rustic

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


---

How to:
```shell
home-server jobs rustic dropbox-backup backup
```


https://www.dropbox.com/developers/apps