FROM php:5.6-fpm

COPY config/php.ini /usr/local/etc/php/php.ini

RUN apt-get update && apt-get install -y \
        apt-transport-https \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libxml2-dev \
		libicu-dev \
		libpq-dev \
		freetds-bin \
        freetds-common \
        freetds-dev \
        nano \
        git \
	&& docker-php-ext-install -j$(nproc) xmlrpc \
	    zip \
	    intl \
	    soap \
	    opcache \
	    pdo_pgsql \
	    pdo_mysql \
	    pgsql \
	    mysqli \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

# we need en_AU locales for behat to work

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

RUN apt-get update && apt-get install -y \
    libsybdb5 \
    freetds-common \
    freetds-dev \
    freetds-bin \
    unixodbc \
    libct4

RUN cd /usr/lib && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a

RUN docker-php-ext-install -j$(nproc) mssql

COPY config/freetds.conf /etc/freetds/freetds.conf

RUN cd / && git clone https://github.com/wolfcw/libfaketime.git \
    && cd /libfaketime/src && make install

RUN apt-get update && apt-get install -y tzdata

ENV TZ "Pacific/Auckland"
RUN echo "${TZ}" > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata
