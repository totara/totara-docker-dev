FROM totara/docker-dev-php71:latest

RUN pecl install -f xdebug-2.9.8 && docker-php-ext-enable xdebug.so
RUN pecl install -f pcov && docker-php-ext-enable pcov.so

RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/xdebug.ini