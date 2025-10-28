# Rustic

Requirements:
- Backblaze account with B2 Storage active

## Initial setup

1. Create a bucket in Backblaze.
2. Setup the secrets:
   1. The `secrets.toml` containing the integration settings.
   2. The `repository_password.secret` containing the password to encrypt/decrypt the backup.
3. Init the repository: `home-server tasks backup-blaze backup init`

Once done, create a Cronjob:
1. Create a User Defined Script (as root due to limitation)
2. Set the script to run daily at night.
3. Add the following: `HOME_SERVER_ENV=synology /volume1/homes/Bruno-Admin/home-server/bin/home-server.sh tasks backup-blaze backup backup`

## Commands

Backup:
```
$ home-server tasks backup-blaze backup
```

List:
```
$ home-server tasks backup-blaze ls
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
