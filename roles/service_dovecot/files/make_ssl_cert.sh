#!/usr/bin/bash
mv /etc/ssl/certs/dovecot.pem /etc/ssl/certs/dovecot.pem.old
mv /etc/ssl/private/dovecot.pem /etc/ssl/private/dovecot.pem.old
/usr/lib/dovecot/mkcert.sh
cp /etc/ssl/certs/dovecot.pem /etc/ca-certificates/trust-source/anchors/dovecot.crt
trust extract-compat
