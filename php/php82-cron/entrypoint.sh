#!/bin/bash

if [ -e /etc/cron.d/*.cron ]
then
    # Install new crontab using all .cron files
    cat /etc/cron.d/*.cron | crontab - \
    && crontab -l \
    && cron -f
else
    echo "No .cron files found in cron.d folder"
fi