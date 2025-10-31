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
3. Init the repository: `home-server task backup backblaze rustic init`

In Synology, create a user-defined cronjob as `Bruno-Admin`:
```
source /var/services/homes/Bruno-Admin/.bashrc
home-server tasks backup backblaze backup
```

## Commands

Backup: `home-server task backup backblaze backup`
List Snapshots: `home-server task backup backblaze rustic snapshots`
List files: `home-server task backup backblaze rustic ls latest`
Stream single file: `home-server task backbup backblaze rustic dump latest {file}`
