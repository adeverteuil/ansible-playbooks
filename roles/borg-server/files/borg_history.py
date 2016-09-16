#!/usr/bin/python3

"""Report archives for each host in the borg repository.

Assumes archive names have the following format:

    fully.qualified.domain.name_yyyy-mm-ddThh:mm:ss

Example output:

    host1.example.com ┿┿││┿┿┿
    host2.example.com ┿┿│┿┿┿│
    host3.example.com ┿┿│┿┿┿┿
    host4.example.com ┿┿┿┿┿┿┿
                      ││││││└─ 2016-09-15 21:00
                      │││││└── 2016-09-15 20:00
                      ││││└─── 2016-09-15 19:00
                      │││└──── 2016-09-15 18:00
                      ││└───── 2016-09-15 17:00
                      │└────── 2016-09-15 16:00
                      └─────── 2016-09-15 15:00
"""

from collections import defaultdict
from datetime import datetime
from subprocess import check_output, CalledProcessError
import sys

try:
    list_output = check_output(["borg", "list", "/var/lib/attic/repository"])
except CalledProcessError:
    print("Failed to query the list of archive in the borg repository.")
    sys.exit(1)
times = defaultdict(set)
hosts = set()
for line in list_output.splitlines():
    archive = line.split(maxsplit=1)[0].decode()
    host, timestamp = archive.split("_", maxsplit=1)
    t = datetime.strptime(timestamp[:13], "%Y-%m-%dT%H")
    times[t].add(host)
    hosts.add(host)

width1 = max(len(host) for host in hosts)
for host in sorted(hosts, key=lambda h: ".".join(reversed(h.split(".")))):
    print("{:>{}} ".format(host, width1), end="")
    for time in sorted(times):
        print("┿" if host in times[time] else "│", end="")
    print()
for index, time in zip(range(len(times)), sorted(times, reverse=True)):
    t = time.strftime("%Y-%m-%d %H:00")
    asciiart = ("│" * (len(times) - (index + 1))) + "└─" + ("─" * index)
    print("{} {} {}".format(" "*width1, asciiart, t))
