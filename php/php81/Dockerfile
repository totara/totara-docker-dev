FROM php:8.1-fpm-alpine

ARG TARGETARCH
ARG TIME_ZONE=Pacific/Auckland

RUN apk add --no-cache --update \
        linux-headers \
        aspell \
        autoconf \
        bash \
        bc \
        curl \
        icu \
        icu-data-full \
        freetds \
        freetype \
        ghostscript \
        git \
        gnupg \
        graphviz \
        libldap \
        libjpeg \
        libmcrypt \
        libmemcached \
        libpng \
        libpq \
        musl \
        musl-utils \
        musl-locales \
        musl-locales-lang \
        nano \
        openssl \
        tzdata \
        vim \
        wget \
        zip \
    && apk add --no-cache --virtual build-dependencies \
        curl-dev \
        freetype-dev \
        freetds-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
        libzip-dev \
        icu-dev \
        openldap-dev \
        unixodbc-dev \
        gcc \
        make \
        g++ \
    && docker-php-ext-install -j$(nproc) zip \
        intl \
        soap \
        opcache \
        pdo_pgsql \
        pdo_mysql \
        pgsql \
        mysqli \
        exif \
        ldap \
        pdo_dblib \
    && docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone https://github.com/tideways/php-profiler-extension.git \
    && cd php-profiler-extension \
    && phpize \
    && ./configure \
    && make && make install

RUN echo "extension=tideways_xhprof.so" >> /usr/local/etc/php/conf.d/tideways_xhprof.ini

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN pecl install -o -f igbinary \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable igbinary

RUN pecl install -o -f memcached \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable memcached

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Taken from https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
RUN curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/msodbcsql18_18.3.1.1-1_$TARGETARCH.apk && \
    curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/mssql-tools18_18.3.1.1-1_$TARGETARCH.apk

#(Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
RUN curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/msodbcsql18_18.3.1.1-1_$TARGETARCH.sig && \
    curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/mssql-tools18_18.3.1.1-1_$TARGETARCH.sig

RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - && \
    gpg --verify msodbcsql18_18.3.1.1-1_$TARGETARCH.sig msodbcsql18_18.3.1.1-1_$TARGETARCH.apk && \
    gpg --verify mssql-tools18_18.3.1.1-1_$TARGETARCH.sig mssql-tools18_18.3.1.1-1_$TARGETARCH.apk

# Install the package(s)
RUN apk add --allow-untrusted msodbcsql18_18.3.1.1-1_$TARGETARCH.apk && \
    apk add --allow-untrusted mssql-tools18_18.3.1.1-1_$TARGETARCH.apk

RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv

RUN docker-php-ext-enable sqlsrv.so && docker-php-ext-enable pdo_sqlsrv.so

RUN ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

# Python 3 for ML Recommender.
RUN apk add --no-cache --update python3 \
    py3-pip \
    py3-wheel \
    py3-virtualenv \
    python3-dev

# Remove build dependencies
RUN apk del build-dependencies

COPY config/php.ini /usr/local/etc/php/
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf

# Source each .sh file found in the /shell/ folder
RUN echo 'for f in ~/custom_shell/*.sh; do [[ -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

# Have the option of using the oh my zsh shell.
RUN apk add --no-cache --update zsh
RUN sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
RUN git clone https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN echo 'setopt +o nomatch' > ~/.zshrc
RUN echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc
RUN cat ~/.bashrc >> ~/.zshrc
