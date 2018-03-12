FROM derschatta/totara-dev-php54:latest

RUN pecl install xdebug-2.4.1

RUN echo "[xdebug]" >> /etc/php5/conf.d/xdebug.ini \
    && echo "zend_extension=/usr/lib/php5/20100525/xdebug.so" >> /etc/php5/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php5/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php5/conf.d/xdebug.ini
