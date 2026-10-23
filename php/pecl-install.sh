#!/bin/sh
set -u

# Downloads pecl packages with curl, retrying as downloads from pecl.php.net fail now and then, then installs them with pecl install -o.
# Pin a version on each package (e.g. redis-6.3.0) so builds don't pick up whatever pecl.php.net has as latest.

# pecl runs make with one job by default, make picks up -j from MAKEFLAGS
MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export MAKEFLAGS

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir" || exit 1

for package in "$@"; do
    curl --fail --silent --show-error --location --retry 3 --retry-all-errors --retry-delay 10 \
        -O "https://pecl.php.net/get/$package.tgz" || exit 1
done

pecl install -o ./*.tgz
