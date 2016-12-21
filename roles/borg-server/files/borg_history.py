#!/usr/bin/python3

"""Report archives for each host in the borg repository.

Assumes archive names have the following format:

    fully.qualified.domain.name_yyyy-mm-ddThh:mm:ss

Example output:

    host1.example.com ┿┿││┿┿┿
    host2.example.com ┿┿│┿┿┿│
    host3.example.com ┿┿│┿┿┿┿
    host4.example.com ┿┿┿┿┿┿┿
                      2211111
                      1098765

                      1111111
                      5555555

                      0000000
                      9999999

                      2222222
                      0000000
                      1111111
                      6666666
"""

from collections import defaultdict
from datetime import datetime
from subprocess import check_output, CalledProcessError
import sys

try:
    list_output = check_output(["borg", "list", "--short", "/var/lib/attic/repository"])
except CalledProcessError:
    print("Failed to query the list of archives in the borg repository.")
    sys.exit(1)
times = defaultdict(set)
hosts = set()
for line in list_output.splitlines():
    host, timestamp = line.decode().split("_", maxsplit=1)
    t = datetime.strptime(timestamp[:13], "%Y-%m-%dT%H")
    times[t].add(host)
    hosts.add(host)

width1 = max(len(host) for host in hosts)
for host in sorted(hosts, key=lambda h: ".".join(reversed(h.split(".")))):
    print("{:>{}} ".format(host, width1), end="")
    for time in sorted(times):
        print("┿" if host in times[time] else "│", end="")
    print()
timestamps = [t.strftime("%H %d %m %Y") for t in sorted(times)]
width2 = width1 - 2
for line in map(''.join, zip(*["hh dd mm yyyy", "             "]+timestamps)):
    print("{} {}".format(" "*width2, line))
