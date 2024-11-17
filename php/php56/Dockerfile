FROM php:5.6-fpm

ARG TIME_ZONE=Pacific/Auckland

# Debian stretched moved to the archives
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list \
    && sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

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
        vim \
        git \
        locales \
        tzdata \
        libmemcached-dev \
        zip \
        netcat \
        bc \
        ghostscript \
        graphviz \
        aspell \
        libsybdb5 \
        freetds-bin \
        unixodbc \
        libct4 \
        wget \
    && docker-php-ext-install -j$(nproc) xmlrpc \
        zip \
        intl \
        soap \
        opcache \
        pdo_pgsql \
        pdo_mysql \
        pgsql \
        mysqli \
        exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

COPY pecl /root/pecl

# Base image is outdated and thus cannot check the certificates, added the needed pecl packages for offline installation
RUN  pecl install --offline /root/pecl/xhprof-0.9.4.tgz \
    && docker-php-ext-enable xhprof

RUN pecl install --offline /root/pecl/redis-4.3.0.tgz \
    &&  docker-php-ext-enable redis

RUN pecl install --offline /root/pecl/igbinary-2.0.8.tgz \
    &&  docker-php-ext-enable igbinary

RUN pecl install --offline /root/pecl/memcached-2.2.0.tgz \
    &&  docker-php-ext-enable memcached

# we need en_AU locales for behat to work
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN cd /usr/lib && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a

RUN docker-php-ext-install -j$(nproc) mssql

COPY config/freetds.conf /etc/freetds/freetds.conf

RUN cd / && git clone https://github.com/wolfcw/libfaketime.git \
    && cd /libfaketime/src && make install

RUN ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf

# Source each .sh file found in the /shell/ folder, always source the default_aliases.sh file first
RUN echo 'if [[ -e "/root/custom_shell/default-aliases.sh" ]]; then source "/root/custom_shell/default-aliases.sh"; fi' >> ~/.bashrc && \
  echo 'for f in /root/custom_shell/*.sh; do [[ "$f" != "/root/custom_shell/default-aliases.sh" && -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

# Have the option of using the oh my zsh shell.
RUN apt-get update && apt-get install -y zsh
RUN sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
RUN git clone https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN echo 'setopt +o nomatch' > ~/.zshrc
RUN echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc
RUN cat ~/.bashrc >> ~/.zshrc
