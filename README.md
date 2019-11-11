# rdailybakup
Daily incremental backup of a local system to a Linux server

This is a project similar to rsnapshot but is done slightly differently. It is implemented completely in bourne shell script, and thus unlike rsnapshot, it does not event depend on perl. It assumes that daily snapshots are stored on a Linux server, and the script itself should be put onto that Linux server. However, it is the job of the client side to initiate a rsync command to invoke the script on the server side. Hence, it is a "push" model where the client (data source) pushes data to the backup Linux server. On the contrary, rsnapshot implements a "pull" model where backup server pulls data from the client (data source). The reason that we choose the push model is because the backup server usually is fixed, but the client (data source) is often "mobile". It is easy for the client (data source) to find the server, instead of the opposite.

The fundamental idea of rdailybackup is the same as rsnapshot - originally based on an article called Easy Automated Snapshot-Style Backups with Linux and Rsync, by Mike Rubel. It exploits a clever Unix file system feature called hard link to let same files of different snapshots point to a single file via hard links. Hence, there is only one copy of data but multiple "pointers" of the data in different directories. When data is changed, a new copy of the data is then created in the new snapshot. This avoids duplicates when data does not change.

This tool keeps a set of snapshots on the backup server in different directories. User can access the backup files in the snapshot directories without requiring any additional tools from the operating system. The script can run multiple times in a day, and later run always overwrite the early snapshots on the same day. When the script runs on a new day, it rotates early snapshots.

The script may also work on other Posix compatible system like FreeBSD, though it is not tested.
