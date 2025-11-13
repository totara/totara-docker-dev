FROM php:7.4-fpm-bullseye

ARG TIME_ZONE=Pacific/Auckland

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
        cron \
        nano \
        vim \
        wget \
        openssl \
        locales \
        tzdata \
        git \
        libzip-dev \
        libmemcached-dev \
        zip \
        netcat \
        bc \
        ghostscript \
        graphviz \
        aspell \
        libldap2-dev \
        libltdl-dev \
        xmlstarlet \
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
        ldap \
    && docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone https://github.com/longxinH/xhprof.git ./xhprof \
    && cd xhprof \
    && git checkout v2.3.10 \
    && cd extension/ \
    && phpize \
    && ./configure \
    && make && make install

RUN echo "extension=xhprof.so" >> /usr/local/etc/php/conf.d/xhprof.ini \
    && echo "xhprof.output_dir = /tmp/xhprof" >> /usr/local/etc/php/conf.d/xhprof.ini

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN pecl install -o -f igbinary \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable igbinary

RUN pecl install -o -f memcached \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable memcached

RUN pecl install -o -f xdebug-3.1.6 \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable xdebug.so

RUN pecl install -o -f pcov \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable pcov

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# we need en_US locales for MSSQL connection to work
# we need en_AU locales for behat to work
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# install mssql extension
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql18 \
    mssql-tools18 \
    unixodbc-dev

RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Workaround applied: https://github.com/microsoft/msphpsql/issues/1438#issuecomment-1444773949
RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system \
    && pecl install sqlsrv-5.10.1 pdo_sqlsrv-5.10.1 || \
    apt-get install -y --allow-downgrades odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc=2.3.7 unixodbc-dev=2.3.7 && \
    pecl install sqlsrv-5.10.1 pdo_sqlsrv-5.10.1

RUN docker-php-ext-enable sqlsrv.so && docker-php-ext-enable pdo_sqlsrv.so

RUN ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Python 3.7 for ML Recommender.
RUN apt-get update && apt install -y python3 \
    python3-pip \
    python3-wheel \
    python3-venv \
    python3-dev

COPY config/php.ini /usr/local/etc/php/
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf

# Source each .sh file found in the /shell/ folder, always source the default_aliases.sh file first
RUN echo 'if [[ -e "/root/custom_shell/default-aliases.sh" ]]; then source "/root/custom_shell/default-aliases.sh"; fi' >> ~/.bashrc && \
  echo 'for f in /root/custom_shell/*.sh; do [[ "$f" != "/root/custom_shell/default-aliases.sh" && -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

# Have the option of using the oh my zsh shell.
RUN apt-get update && apt-get install -y zsh
RUN sh -c "$(curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
RUN git clone https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN echo 'setopt +o nomatch' > ~/.zshrc
RUN echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc
RUN cat ~/.bashrc >> ~/.zshrc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
