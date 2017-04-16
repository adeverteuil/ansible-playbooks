#!/bin/bash
/usr/bin/letsencrypt renew --post-hook "systemctl reload nginx"
