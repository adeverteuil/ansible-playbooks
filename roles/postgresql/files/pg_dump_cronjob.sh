#!/bin/bash

# Setup
backup_path="/var/backups/postgresql"
date=$(date +"%Y-%m-%d_%H:%M")
umask 177

# Do the backup
sudo -u postgres pg_dumpall > "$backup_path/dump.$date.sql"

# Delete files older than 30 days, making sure at least 10 backups would remain.
if [ $(find "$backup_path" -name "dump.*.sql" -mtime -30 | wc -l) -gt 10 ]; then
    find "$backup_path" -name "dump.*.sql" -mtime +30 -exec rm '{}' \;
fi
