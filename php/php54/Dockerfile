FROM ubuntu:16.04

ARG TIME_ZONE=Pacific/Auckland

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    tzdata \
    locales \
    nano \
    wget \
    git \
    unixodbc \
    libsybdb5 \
    freetds-bin \
    freetds-common \
    freetds-dev \
    autoconf

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libfcgi-dev \
    libfcgi0ldbl \
    libjpeg62-dbg \
    libxml2-dev \
    libmcrypt-dev \
    libssl-dev \
    libc-client2007e \
    libc-client2007e-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libkrb5-dev \
    libpq-dev \
    libicu-dev

RUN ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a

RUN mkdir /usr/local/php \
    && mkdir /usr/local/src/php5-build

RUN cd /usr/local/src/php5-build \
    && wget https://www.php.net/distributions/php-5.4.45.tar.bz2 \
    && tar jxf php-5.4.45.tar.bz2

RUN cd /usr/local/src/php5-build/php-5.4.45/ \
    && ./configure --prefix=/usr/local/php --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring \
    --with-libxml-dir=/usr --enable-soap --enable-intl --enable-calendar --with-curl --with-mcrypt --with-zlib \
    --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets \
    --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash \
    --enable-zip --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-mssql --with-jpeg-dir=/usr --with-png-dir=/usr \
    --enable-gd-native-ttf --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data \
    --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-gettext --with-xmlrpc --with-xsl \
    --with-kerberos --enable-fpm \
    && make \
    && make install

RUN cp /usr/local/src/php5-build/php-5.4.45/php.ini-production /usr/local/php/lib/php.ini \
    && cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf \
    && mkdir /usr/local/php/etc/php-fpm.d

RUN echo 'zend_extension=opcache.so' >> /usr/local/php/lib/php.ini

COPY config/freetds.conf /etc/freetds/freetds.conf

RUN sed -i "s|;pid = run/php-fpm.pid|pid = run/php-fpm.pid|" /usr/local/php/etc/php-fpm.conf \
    && sed -i "s|;include=etc/fpm.d/\*.conf|include=/usr/local/php/etc/php-fpm.d/\*.conf|" /usr/local/php/etc/php-fpm.conf \
    && sed -i 's|error_log = /var/log/php5-fpm.log|error_log = /proc/self/fd/2|g' /usr/local/php/etc/php-fpm.conf \
    && sed -i "s|listen = 127.0.0.1:9000|listen = 9000|" /usr/local/php/etc/php-fpm.conf \
    && sed -i 's|pm.max_children = 5|pm.max_children = 16|g' /usr/local/php/etc/php-fpm.conf

RUN ln -s /usr/local/php/bin/php /usr/bin/php

RUN echo ${TIME_ZONE} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

COPY config/php.ini /tmp/php.ini
RUN cat /tmp/php.ini >> /usr/local/php/lib/php.ini
COPY config/fpm.conf /usr/local/php/etc/php-fpm.d/zz-totara.conf

# Source each .bash file found in the /bash/ folder
RUN echo 'for f in ~/custom_bash/*.bash; do [[ -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

EXPOSE 9000

CMD ["/usr/local/php/sbin/php-fpm", "-F"]