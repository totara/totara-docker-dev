FROM totara/docker-dev-php72:latest

RUN pecl install -f xdebug-3.1.1 && docker-php-ext-enable xdebug.so
RUN pecl install -f pcov && docker-php-ext-enable pcov.so

RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/xdebug.ini
