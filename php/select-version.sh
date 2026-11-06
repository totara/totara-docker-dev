#!/bin/sh
set -eu

# Picks which of the PHP versions installed in this image the php, phar, phpize, php-config and php-fpm
# commands run. The entrypoint calls it with PHP_VERSION when the container starts, and the image build
# calls it once per version to build and test each one.

version="${1:-}"
if [ -z "$version" ] || [ ! -d "/etc/php/$version" ]; then
    echo "Usage: totara-php-select <version>, one of: $(ls /etc/php | tr '\n' ' ')" >&2
    exit 1
fi

for name in php phar phar.phar phpize php-config; do
    if update-alternatives --query "$name" > /dev/null 2>&1; then
        update-alternatives --quiet --set "$name" "/usr/bin/$name$version"
    fi
done

# php-fpm has no alternative, and the Debian package expects its pid directory to exist
ln -sf "/usr/sbin/php-fpm$version" /usr/local/sbin/php-fpm
mkdir -p /run/php
