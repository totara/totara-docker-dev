FROM php:7.0-fpm

ARG TIME_ZONE=Pacific/Auckland

COPY config/php.ini /usr/local/etc/php/
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-transport-https \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libxml2-dev \
		libicu-dev \
		libpq-dev \
		gnupg2 \
		nano \
		wget \
		openssl \
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

# we need en_US locales for MSSQL connection to work
# we need en_AU locales for behat to work
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# install mssql extension
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/8/prod.list | tee /etc/apt/sources.list.d/mssql-tools.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -y \
    unixodbc \
    libgss3 \
    unixodbc-dev \
    msodbcsql=13.1.9.2-1 \
    mssql-tools=14.0.7.0-1

RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv

RUN ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
