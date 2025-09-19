FROM totara/docker-dev-php84:latest

RUN pecl channel-update pecl.php.net && pecl install -f xdebug-3.4.0 && docker-php-ext-enable xdebug.so

RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/xdebug.ini
