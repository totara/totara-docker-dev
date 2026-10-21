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

# Build a regex of the PHP versions (e.g. 82 for PHP 8.2) that can be accessed via ngrok
ngrok_min_php="${NGROK_MIN_PHP_VERSION//./}"
ngrok_php_versions=()
for version in {10..99}; do
    if (( version >= ngrok_min_php )); then
        ngrok_php_versions+=("$version")
    fi
done
ngrok_php_regex="^($(IFS='|'; echo "${ngrok_php_versions[*]}"))\$"
sed "s/\$NGROK_PHP_REGEX/$ngrok_php_regex/g" /tmp/remote-server.conf > /usr/local/apache2/conf.d/remote-server.conf

httpd -D "FOREGROUND" -k start
