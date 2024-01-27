#!/bin/sh

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
        -subj "/C=US/ST=CA/L=SF/O=Docker-demo/CN=totara" \
        -keyout /etc/nginx/ssl/domain.key \
        -out /etc/nginx/ssl/domain.crt
fi

# set dataroot permissions
chown www-data:www-data $REMOTE_DATA -R

# Replace the remote src variable in the nginx configuration with
# the one defined in the environment variables
cp /etc/nginx/totara-server.conf /tmp/temp.conf
envsubst '$REMOTE_SRC' < /tmp/temp.conf > /etc/nginx/totara-server.conf
rm /tmp/temp.conf

# fire up nginx
nginx -g 'daemon off;'
