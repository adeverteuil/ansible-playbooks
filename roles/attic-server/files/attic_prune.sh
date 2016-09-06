#!/bin/bash

REPOSITORY=/var/lib/attic/repository

attic list $REPOSITORY | sed -r "s/^([a-zA-Z0-9\.-]*)-([^ ]{24})(\.checkpoint)? .*/\1/" | sort -u | \
while read prefix; do  #                              ^^ Length of "yyyy-mm-ddThh:mm:ss-zzzz"
    flock $REPOSITORY/lock \
    attic prune $REPOSITORY \
        --keep-hourly 24 \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 3 \
        --prefix $prefix
done
