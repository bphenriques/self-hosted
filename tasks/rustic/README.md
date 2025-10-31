# Rustic

Requirements:
- Backblaze account with B2 Storage plan
- Dropbox account

## Initial setup

### Backblaze

1. Create a bucket in Backblaze:

   1. Encryption is not required as the files will be encrypted by Rustic.
   2. Ensure Lifecycle settings are set to "Keep only the last version of the file".
   3. The type is set to 'Private'.

2. Setup the secrets using the example file as starting point.
3. Init the repository: `home-server tasks backup backblaze rustic init`

In Synology, create a user-defined cronjob as root (b/c we need to convert root permissions to user permissions):
```
source /var/services/homes/Bruno-Admin/.bashrc
home-server task backup backblaze backup
```

## Commands

Backup:
```
$ home-server tasks backup backblaze backup
```

List:
```
$ home-server tasks backup backblaze rustic snapshots
```

## Test

FIXME

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
