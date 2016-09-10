#!/bin/bash

REPOSITORY=/var/lib/attic/repository

(
if ! flock -n 9; then
  echo "Couldn't acquire lock /$REPOSITORY/prune.lock"
  exit 1
fi
borg list $REPOSITORY | sed -r "s/^([a-zA-Z0-9\.-]*)_.*/\1/" | sort -u | \
while read prefix; do
    flock $REPOSITORY/lock \
    borg prune $* $REPOSITORY \
        --keep-within 24H \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 3 \
        --prefix $prefix
done
) 9>$REPOSITORY/prune.lock
