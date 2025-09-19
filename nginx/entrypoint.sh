#!/bin/bash

# if there's no ssl certificate yet create it
if [ ! -f "/etc/nginx/ssl/domain.crt" ]
then
    mkdir -p /etc/nginx/ssl
    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 3650 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=CA/L=SF/O=Docker-dev/CN=totara" \
        -keyout /etc/nginx/ssl/domain.key \
        -out /etc/nginx/ssl/domain.crt
fi

# set dataroot permissions
chown www-data:www-data $REMOTE_DATA -R

# fire up nginx
nginx -g 'daemon off;'
