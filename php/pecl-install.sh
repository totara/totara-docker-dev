#!/bin/sh
set -u

# Downloads pecl packages, retrying as downloads from pecl.php.net fail now and then, then installs them with pecl install -o.
# Pin a version on each package (e.g. redis-6.3.0) so builds don't pick up whatever pecl.php.net has as latest.

pecl channel-update pecl.php.net || echo "pecl channel-update failed, carrying on with the current channel data" >&2

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir" || exit 1

for package in "$@"; do
    attempt=1
    until pecl download "$package"; do
        if [ "$attempt" -ge 3 ]; then
            echo "pecl download $package failed after $attempt attempts" >&2
            exit 1
        fi
        echo "pecl download $package failed, retrying in $((attempt * 10))s" >&2
        sleep $((attempt * 10))
        attempt=$((attempt + 1))
    done
done

pecl install -o ./*.tgz
