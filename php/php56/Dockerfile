FROM php:5.6-fpm

ARG TIME_ZONE=Pacific/Auckland

COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf

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
        locales \
        tzdata \
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

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

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

RUN ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
