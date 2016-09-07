#!/bin/bash

cd /var/lib/attic
if [ -e /var/lib/attic/repository/lock ]; then
  flock /var/lib/attic/repository/lock attic serve --restrict-to-path /var/lib/attic
else
  exit 1
fi
