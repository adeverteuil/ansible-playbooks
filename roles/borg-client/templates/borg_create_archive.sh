#!/bin/bash
# {{ ansible_managed }}
# The PATHS variable value is from a template variable.
# Any parameters will be appended to the OPTIONS.
# You can pass the -v and -s parameters if you invoke the script from an
# interactive terminal.

NICE="nice -n 10 ionice -c 2 -n 3"
REPOSITORY="{{ borg_repository }}"
ARCHIVE="{fqdn}_{now:%Y-%m-%dT%H:%M:%S}"
BORG="borg create ${REPOSITORY}::${ARCHIVE}"
OPTIONS="--exclude-from /etc/borg.exclude --exclude-if-present .backup.exclude --keep-tag-files --one-file-system --compression lz4"
PATHS="{{ borg_backup_paths }}"

(
if ! flock -n 9; then
  echo "Couldn't acquire lock /run/borg.lock"
  exit 1
fi
if [ ".$*" != "." ]; then
  $BORG $PATHS $OPTIONS $*
else
  export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
  stdout=$($NICE $BORG $PATHS $OPTIONS 2>&1) || echo $stdout
fi
) 9>/run/borg.lock
