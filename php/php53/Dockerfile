FROM totara/docker-dev-php-base:latest

# This is the PHP version we want to install
ENV PHPVERSION 5.3.29

# Install php version with desired extensions
RUN phpbrew install -j $(nproc) $PHPVERSION \
    +default \
    +fpm \
    +iconv \
    +icu \
    +intl \
    +mysql \
    +pcntl \
    +pdo \
    +pgsql \
    +soap \
    +sqlite \
    +xmlrpc \
    +zlib \
    -- \
    --enable-gd-native-ttf \
    --with-fpm-group=www-data \
    --with-fpm-user=www-data \
    --with-freetype-dir \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-libdir=/lib/x86_64-linux-gnu \
    --with-mssql \
    --with-png-dir=/usr

RUN phpbrew clean php-$PHPVERSION

ENV PHPBREW_PHP php-$PHPVERSION

# Copy custom config file contents
RUN mkdir -p /root/.phpbrew/php/php-$PHPVERSION/etc/fpm.d
COPY config/freetds.conf /etc/freetds/freetds.conf
COPY config/php-fpm.conf /root/.phpbrew/php/php-$PHPVERSION/etc/php-fpm.conf
COPY config/php.ini /tmp/php.ini
# We just append additional php.ini vars
RUN cat /tmp/php.ini >> /root/.phpbrew/php/php-$PHPVERSION/etc/php.ini

# Set PATH to phpbrew bin folder
ENV PATH /root/.phpbrew/php/php-$PHPVERSION/bin:$PATH

EXPOSE 9000

CMD ["/bin/bash", "-c", "/root/.phpbrew/php/php-$PHPVERSION/sbin/php-fpm"]
