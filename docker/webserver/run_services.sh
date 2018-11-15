#!/bin/bash

# Stop postfix. It doesn't seem to work properly if not run as a service
postfix stop

# Start syslog (needs to be before postfix)
service rsyslog start

# Start postfix
service postfix start

/opt/ctcserve/init_letsencrypt.sh

#certbot install --apache --cert-name ctc.05081986.xyz --redirect

set -e
# Yanked from https://github.com/docker-library/php/blob/79436c81bdc8ebea0f6369a0b7f368127acc871e/5.6/jessie/apache/apache2-foreground

# Note: we don't just use "apache2ctl" here because it itself is just a shell-script wrapper around apache2 which provides extra functionality like "apache2ctl start" for launching apache2 in the background.
# (also, when run as "apache2ctl <apache args>", it does not use "exec", which leaves an undesirable resident shell process)

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
    . "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_RUN_DIR:=/var/run/apache2}"
: "${APACHE_PID_FILE:=$APACHE_RUN_DIR/apache2.pid}"
rm -f "$APACHE_PID_FILE"

# create missing directories
# (especially APACHE_RUN_DIR, APACHE_LOCK_DIR, and APACHE_LOG_DIR)
for e in "${!APACHE_@}"; do
    if [[ "$e" == *_DIR ]] && [[ "${!e}" == /* ]]; then
        # handle "/var/lock" being a symlink to "/run/lock", but "/run/lock" not existing beforehand, so "/var/lock/something" fails to mkdir
        #   mkdir: cannot create directory '/var/lock': File exists
        dir="${!e}"
        while [ "$dir" != "$(dirname "$dir")" ]; do
            dir="$(dirname "$dir")"
            if [ -d "$dir" ]; then
                break
            fi
            absDir="$(readlink -f "$dir" 2>/dev/null || :)"
            if [ -n "$absDir" ]; then
                mkdir -p "$absDir"
            fi
        done

        mkdir -p "${!e}"
    fi
done

exec apache2 -DFOREGROUND "$@"
