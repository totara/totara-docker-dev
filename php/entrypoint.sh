#!/bin/bash

# Install new crontab using all .cron files
if [[ -n $CONTAINERNAME && $CONTAINERNAME == $CRON_CONTAINER ]]; then
    if [ -e /etc/cron.d/*.cron ]; then
        cat /etc/cron.d/*.cron | crontab - \
        && crontab -l \
        && cron -f
        echo ".cron files found in cron.d folder, installing new crontab and starting cron daemon"
    else
        echo "No .cron files found in cron.d folder, skipping crontab installation"
    fi
else
    echo "Not the designated cron container (CRON_CONTAINER: ${CRON_CONTAINER:-none}), skipping crontab installation"
fi

# Generate random seed file for openssl
# This prevents openssl from complaining about not having enough entropy
openssl rand -writerand /root/.rnd

# Refuse to start on a PHP build older than the minimum this image is expected to ship.
# The minimums are the releases that fix CVE-2026-109618 and CVE-2026-109619
# (see https://github.com/php/php-src/security/advisories). Older branches (8.1 and
# below) are end-of-life and received no fix, so they are not checked here.
case "$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')" in
    8.2) MIN_PHP_VERSION=8.2.35 ;;
    8.3) MIN_PHP_VERSION=8.3.36 ;;
    8.4) MIN_PHP_VERSION=8.4.27 ;;
    8.5) MIN_PHP_VERSION=8.5.12 ;;
    *)   MIN_PHP_VERSION= ;;
esac
if [[ -n $MIN_PHP_VERSION ]] && ! php -r 'exit(version_compare(PHP_VERSION, $argv[1], ">=") ? 0 : 1);' "$MIN_PHP_VERSION"; then
    echo "PHP $(php -r 'echo PHP_VERSION;') detected, but this image requires at least PHP ${MIN_PHP_VERSION}."
    echo "Please pull or rebuild the image (e.g. 'tpull' / 'tbuild') to get the patched PHP release."
    exit 1
fi

php-fpm
