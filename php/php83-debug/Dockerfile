FROM totara/docker-dev-php83:latest

RUN pecl install -f xdebug-3.4.0beta1 && docker-php-ext-enable xdebug.so
RUN pecl install -f pcov && docker-php-ext-enable pcov.so

RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/xdebug.ini

# Set some sensible defaults
RUN echo "pcov.enabled=1" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini \
    && echo "pcov.exclude='~(vendor|tests|node_modules|.git|client|.scannerwork)~'" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini \
    # The next line can be enabled (and applied with tbuild and tup of this container) to optimise memory usage \
    # Note that PHP's memory limit needs to be high enough.
    #&& echo "pcov.initial.memory=1073741824" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini \
    && echo "pcov.initial.files=30000" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini