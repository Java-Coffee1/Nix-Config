4. Recovering files

First load the same settings the script uses:

```
set -a; source /run/agenix/backup-env; set +a
export RESTIC_REPOSITORY="sftp://java@java-files.shelvacu.com:26101//data"
```

Then use whichever of these fits:

```
restic snapshots
restic ls latest /mnt/cloud-data-dump
restic restore latest --target /tmp/restore --include /mnt/cloud-data-dump/some/folder
restic mount /mnt/restic
restic dump latest /mnt/cloud-data-dump/file.txt > file.txt
```
What each one does:

snapshots lists your backups.
ls shows what’s inside one.
restore pulls files back. It recreates the full path under the target, so you’d get /tmp/restore/mnt/cloud-data-dump/.... Restore to a temporary folder and copy back from there, not straight over the live folder.
mount lets you browse every snapshot as normal folders. The docs say it’s best for grabbing a few files; use restore for big ones.
dump writes a single file to stdout.

On a brand-new machine, all you need is restic, SSH access to java-files, and that password. That’s why your user key needs to be on the secret.


Run it the same way the timer does (recommended, since it tests the real setup as root):

```
sudo systemctl start ext-database-backup.service
```
Since it’s a oneshot service, the command waits until the backup finishes. To watch the output live, run this in a second terminal:

```
journalctl -u ext-database-backup -f
```

Run the script directly as yourself:

```
ext-database-backup
```