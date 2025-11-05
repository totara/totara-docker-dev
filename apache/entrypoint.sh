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

# Replace the remote src variable in the apache configuration with
# the one defined in the environment variables
sed "s|\$REMOTE_SRC|$REMOTE_SRC|g" /tmp/server.conf > /usr/local/apache2/conf.d/server.conf

httpd -D "FOREGROUND" -k start
