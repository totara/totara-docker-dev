FROM totara/docker-dev-php55:latest

RUN cd /usr/local/src/php5-build && wget https://pecl.php.net/get/xdebug-2.5.5.tgz && tar -xzf xdebug-2.5.5.tgz

RUN cd /usr/local/src/php5-build/xdebug-2.5.5 \
    && /usr/local/php/bin/phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

RUN echo "zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/xdebug.so" >> /usr/local/php/lib/php.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/php/lib/php.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/php/lib/php.ini
