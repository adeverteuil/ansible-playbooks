#!/bin/bash
#
# Run as a cron job, trigger manually or through Ansible tasks

# What this script does:
#
# * Calculate the sha256 digest of Let's Encrypt certificates
# * Compare the computed digests with the ones in cache
# * If there is a difference or the cache is empty:
#     * Concatenate the certificate and key files into /etc/haproxy/certs
#     * Reload/restart HAProxy
#     * Store the new sha256 digests in the cache
#     * Print "CHANGED" on stdout for Ansible idempotency logic


CACHE_DIR="/var/cache/refresh_certs"
CACHE_FILE="${CACHE_DIR}/certs.sha256"
SHOULD_RUN=0
HAPROXY_SERVICE="haproxy"
HAPROXY_CERTS_DIR="/etc/haproxy/certs"

# Initialization
tmpfile="$(mktemp -t "certs_XXXXXXX.sha256")"
mkdir -p "${CACHE_DIR}"

# Compute the current digests for "live" Let's Encrypt certificates
sha256sum /etc/letsencrypt/live/*/* >$tmpfile

# Run if there is a difference between the computed and cached values
if ! [ -r "${CACHE_FILE}" ] || ! diff -q "${CACHE_FILE}" "${tmpfile}" >/dev/null; then
    SHOULD_RUN=1
fi

# Run if any concatenated .pem file is missing in /etc/haproxy/certs
for dir in $(find /etc/letsencrypt/live -mindepth 1 -maxdepth 1 -type d); do
    if ! [ -r "${HAPROXY_CERTS_DIR}/$(basename "${dir}").pem" ]; then
      SHOULD_RUN=1
    fi
done

if [ "${SHOULD_RUN}" -eq 1 ]; then
    mkdir -p "${HAPROXY_CERTS_DIR}"
    for dir in $(find /etc/letsencrypt/live -mindepth 1 -maxdepth 1 -type d); do
        cat "${dir}/fullchain.pem" "${dir}/privkey.pem" > "${HAPROXY_CERTS_DIR}/$(basename "${dir}").pem"
    done
    # Restart haproxy only if is already running
    if service "${HAPROXY_SERVICE}" status >/dev/null; then
      service "${HAPROXY_SERVICE}" "{{ haproxy_restart_method }}" >/dev/null
    fi
    mv "${tmpfile}" "${CACHE_FILE}"
    echo CHANGED
else
    rm "${tmpfile}"
fi
