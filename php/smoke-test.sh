#!/bin/sh
set -eu

check_php_extension() {
    extension="$1"
    if ! php -r "exit(extension_loaded('$extension') ? 0 : 1);"; then
        echo "Missing PHP extension: ${extension}" >&2
        exit 1
    fi
}

check_locale() {
    locale_name="$1"
    if ! locale -a | grep -qi "^${locale_name}[.].*utf"; then
        echo "Missing locale: ${locale_name}.UTF-8" >&2
        exit 1
    fi
}

php -v >/dev/null
composer --version >/dev/null
php-fpm -t

for extension in \
    gd \
    igbinary \
    intl \
    ldap \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xdebug \
    xhprof \
    zip
do
    check_php_extension "$extension"
done

# TODO: PHP 8.6 has no release of memcached, pcov or redis that works on it yet
if ! php -r 'exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 6 ? 0 : 1);'; then
    check_php_extension memcached
    check_php_extension pcov
    check_php_extension redis
fi

if ! php -r 'exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION >= 5 ? 0 : 1);'; then
    check_php_extension sqlsrv
    check_php_extension pdo_sqlsrv
fi

check_locale en_US
check_locale en_AU
