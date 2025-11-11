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

php-fpm
