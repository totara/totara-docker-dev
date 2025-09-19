FROM totara/docker-dev-php82:latest

RUN pecl install -f xdebug-3.4.0beta1 && docker-php-ext-enable xdebug.so

RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/xdebug.ini
