FROM totara/docker-dev-php55:latest

RUN pecl install -f xdebug-2.5.5

RUN echo "zend_extension=/usr/lib/php5/20121212/xdebug.so" >> /etc/php5/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php5/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php5/conf.d/xdebug.ini

RUN ln -s /etc/php5/conf.d/xdebug.ini /etc/php5/fpm/conf.d/xdebug.ini