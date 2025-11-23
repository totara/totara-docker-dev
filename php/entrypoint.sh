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

# Enforce minimum PHP version for 8.5 series (>= 8.5.2)
if php -r 'exit(PHP_MAJOR_VERSION==8 && PHP_MINOR_VERSION==5 ? 0 : 2);'; then
    if ! php -r 'exit(version_compare(PHP_VERSION, "8.5.2", ">=") ? 0 : 1);'; then
        echo "PHP 8.5 detected, but version $(php -r 'echo PHP_VERSION;') is < 8.5.2."
        echo "Please rebuild/update the image to use php:8.5.2-fpm-bookworm or newer."
        exit 1
    fi
fi

php-fpm
