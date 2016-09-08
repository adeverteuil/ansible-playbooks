#!/bin/bash

REPOSITORY=/var/lib/attic/repository

(
if ! flock -n 9; then
  echo "Couldn't acquire lock /REPOSITORY/prune.lock"
  exit 1
fi
attic list $REPOSITORY | sed -r "s/^([a-zA-Z0-9\.-]*)[/-]([^ ]{24,25})(\.checkpoint)? .*/\1/" | sort -u | \
while read prefix; do  #                                    ^^ Length of "yyyy-mm-ddThh:mm:ss-zzzz"
                       #                                       ^^ "yyyy-mm-ddThh:mm:ss-zz:zz" on Fedora
    flock $REPOSITORY/lock \
    attic prune $* $REPOSITORY \
        --keep-hourly 24 \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 3 \
        --prefix $prefix
done
) 9>$REPOSITORY/prune.lock
