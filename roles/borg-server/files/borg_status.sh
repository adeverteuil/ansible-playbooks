#!/bin/bash
#
# Presents a table of pending and active borg backup jobs. Tells the
# administrator since when each host has established an ssh connection and is
# waiting to acquire the lock, and since when the active job is running.
#
# The process tree for each backup is this:
#
# sshd                      # Parent of all sshd session (not listed)
# └ sshd                    # As user root (root_sshd)
#   └ sshd                  # As the borg user (borg_sshd)
#     └ borg_serve.sh       # Script installed by Ansible (serve)
#       └ flock borg serve  # Waiting its turn (flock)
#         └ borg serve      # This is started when the lock is acquired (borg)
#           └ borg serve    # Spawns a subprocess for some reason (subprocess)
#
# Example output:
#
# remote             root_sshd  borg_sshd  serve  flock  since     borg   since     subprocess
# ------             ---------  ---------  -----  -----  --------  ----   --------  ----------
# host1.example.com  4788       4802       4833   4843   21:00:22  19236  21:21:34  19238
# host2.example.com  4883       4887       4888   4889   21:00:24
# host3.example.com  4730       4810       4840   4858   21:00:22
# host4.example.com  4876       4880       4881   4882   21:00:24

(
echo "remote root_sshd borg_sshd serve flock since    borg since    subprocess"
echo "------ --------- --------- ----- ----- -------- ---- -------- ----------"
netstat -tpW | egrep "ESTABLISHED [[:digit:]]*/sshd: borg" | \
while read conn; do
    remote=$(echo $conn | tr -s " " | cut -d" " -f5 | cut -d: -f1)
    echo -n "$remote "

    root_sshd_pid=$(echo $conn | tr -s " " | cut -d" " -f7 | cut -d/ -f1)
    echo -n "$root_sshd_pid "

    borg_sshd_pid=$(ps --ppid $root_sshd_pid -o pid --no-headers)
    echo -n "$borg_sshd_pid "

    serve_pid=$(ps --ppid $borg_sshd_pid -o pid --no-headers)
    echo -n "$serve_pid "

    flock_pid=$(ps --ppid $serve_pid -o pid --no-headers)
    echo -n "$flock_pid "

    echo -n "$(ps -p $flock_pid -o start --no-headers) "

    borg_pid=$(ps --ppid $flock_pid -o pid --no-headers)
    echo -n "$borg_pid "

    if [ ".$borg_pid" != "." ]; then
        echo -n "$(ps -p $borg_pid -o start --no-headers) "

        borg_subp_pid=$(ps --ppid $borg_pid -o pid --no-headers)
        echo -n "$borg_subp_pid"
    fi

    echo
done
) | column -t -x
