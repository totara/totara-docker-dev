FROM totara/docker-dev-php72:latest

RUN pecl install -f xdebug && docker-php-ext-enable xdebug.so

RUN echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini