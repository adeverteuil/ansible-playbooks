#!/bin/bash
# {{ ansible_managed }}
# The PATHS variable value is from a template variable.
# Any parameters will be appended to the OPTIONS.
# You can pass the -v and -s parameters if you invoke the script from an
# interactive terminal.

NICE="nice -n 19 ionice -c 2 -n 7"
REPOSITORY="attic@attic.private.deverteuil.net:/var/lib/attic/repository"
ARCHIVE="{{ ansible_fqdn }}/$(date -Iseconds)"
ATTIC="attic create ${REPOSITORY}::${ARCHIVE}"
OPTIONS="--exclude-from /etc/attic.exclude --do-not-cross-mountpoints $*"
PATHS="{{ attic_backup_paths }}"

(
if ! flock -n 9; then
  echo "Couldn't acquire lock /run/attic.lock"
  exit 1
fi
stdout=$($NICE $ATTIC $OPTIONS $PATHS 2>&1) || echo $stdout
) 9>/run/attic.lock
