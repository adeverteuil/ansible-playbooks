#!/bin/bash
set -e

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

for directory in /var/lib/attic/*; do
    if [ ! -r "${directory}/README" ] ||\
       [ "$(cat "${directory}/README")" != "This is a Borg repository" ]
    then
        continue
    fi
    repository="${directory}"
    borg list --short $repository |\
    sed -r "s/^([a-zA-Z0-9\.-]*)_.*/\1/" |\
    sort -u | \
    while read prefix; do
        borg prune $* $repository \
        --keep-within 24H \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 3 \
        --prefix ${prefix}_ \
        --lock-wait 1800
    done
done
