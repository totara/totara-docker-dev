FROM totara/docker-dev-php56:latest

COPY pecl /root/pecl

# Base image is outdated and thus cannot check the certificates, added the needed pecl packages for offline installation
RUN  pecl install --offline /root/pecl/xdebug-2.5.5.tgz \
    && docker-php-ext-enable xdebug.so

RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/xdebug.ini