#!/bin/bash

cd /var/lib/attic
if [ -e /var/lib/attic/repository/lock ]; then
  flock --wait 7170 /var/lib/attic/repository/lock borg serve --restrict-to-path /var/lib/attic --append-only
else
  exit 1
fi
