#!/bin/bash

# if there's no ssl certificate yet create it
if [ ! -f "/usr/local/apache2/conf/server.crt" ]; then
    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 3650 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=CA/L=SF/O=Docker-dev/CN=totara" \
        -keyout /usr/local/apache2/conf/server.key \
        -out /usr/local/apache2/conf/server.crt
fi

# set dataroot permissions
chown www-data:www-data $REMOTE_DATA -R

httpd -D "FOREGROUND" -k start
