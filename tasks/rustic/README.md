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
home-server tasks backup backblaze backup
```

## Commands

Backup: `home-server tasks backup backblaze backup`
List Snapshots: `home-server tasks backup backblaze rustic snapshots`
List files: `home-server tasks backup backblaze rustic ls latest`
Stream single file: `home-server tasks backbup backblaze rustic dump latest {file}`
