#!/bin/bash
set -e

REPOSITORY=/var/lib/attic/repository

(
if ! flock -n 9; then
  echo "Couldn't acquire lock /$REPOSITORY/prune.lock"
  exit 1
fi

if [ -f $REPOSITORY/prune-hosts ]; then
    cat $REPOSITORY/prune-hosts |\
    while read host; do
        archives=$(borg list --short $REPOSITORY | grep -F ${host}_)
        [ -z "$archives" ] && continue
        while read archive; do
            flock $REPOSITORY/lock \
            borg delete $* $REPOSITORY::$archive
            echo archive $archive deleted
        done <<< "$archives"
    done
    rm $REPOSITORY/prune-hosts
fi

borg list --short $REPOSITORY |\
sed -r "s/^([a-zA-Z0-9\.-]*)_.*/\1/" |\
sort -u | \
while read prefix; do
    flock $REPOSITORY/lock \
    borg prune $* $REPOSITORY \
        --keep-within 24H \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 3 \
        --prefix ${prefix}_
done
) 9>$REPOSITORY/prune.lock
