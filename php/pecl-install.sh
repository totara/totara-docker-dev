#!/bin/sh
set -u

# Installs pecl packages with pecl install -o, retrying as downloads from pecl.php.net fail now and then.
# Pin a version on each package (e.g. redis-6.3.0) so builds don't pick up whatever pecl.php.net has as latest.

pecl channel-update pecl.php.net || echo "pecl channel-update failed, carrying on with the current channel data" >&2

attempt=1
until pecl install -o "$@"; do
    if [ "$attempt" -ge 3 ]; then
        echo "pecl install $* failed after $attempt attempts" >&2
        exit 1
    fi
    echo "pecl install $* failed, retrying in $((attempt * 10))s" >&2
    sleep $((attempt * 10))
    attempt=$((attempt + 1))
done
