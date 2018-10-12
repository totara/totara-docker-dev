FROM totara/docker-dev-php56:latest

RUN pecl install -f xdebug-2.5.5

RUN echo "zend_extension=xdebug.so" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini