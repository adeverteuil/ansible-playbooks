#!/bin/bash

# Source: http://simon-davies.name/bash/backing-up-mysql-databases
# Assuming credentials are available in ~/.my.cnf

# Setup
backup_path="/var/backups/mysql"
date=$(date +"%Y-%m-%d_%H:%M")
umask 177

# Do the backup
mysqldump --all-databases > "$backup_path/dump.$date.sql"

# Delete files older than 30 days, making sure at least 10 backups would remain.
if [ $(find "$backup_path" -name "dump.*.sql" -mtime -30 | wc -l) -gt 10 ]; then
    find "$backup_path" -name "dump.*.sql" -mtime +30 -exec rm '{}' \;
fi
