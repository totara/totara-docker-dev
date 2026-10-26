FROM php:8.5-fpm-bookworm AS base

# apt does not retry failed downloads, so a single timed out .deb from the Debian CDN fails
# the whole build. Older suites go cold in the CDN more often, but any suite can time out.
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries

# Extensions are compiled here, only the built .so files and their ini files are copied into the final image
FROM base AS build

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libpng-dev \
        libxml2-dev \
        libicu-dev \
        libpq-dev \
        libzip-dev \
        libmemcached-dev \
        libldap2-dev \
        libc-client-dev \
        libkrb5-dev \
        libssl-dev \
        libpspell-dev \
        libenchant-2-dev \
        libtool \
        bison \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) \
        zip \
        intl \
        soap \
        pdo_pgsql \
        pdo_mysql \
        pgsql \
        mysqli \
        exif \
        ldap \
        pcntl \
        enchant \
    && docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg \
            --with-webp \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone --depth 1 --branch v2.3.10 https://github.com/longxinH/xhprof.git /tmp/xhprof \
    && cd /tmp/xhprof/extension/ \
    && phpize \
    && ./configure \
    && make -j$(nproc) && make install

RUN echo "extension=xhprof.so" >> /usr/local/etc/php/conf.d/xhprof.ini \
    && echo "xhprof.output_dir = /tmp/xhprof" >> /usr/local/etc/php/conf.d/xhprof.ini

COPY pecl-install.sh /usr/local/bin/totara-pecl-install
RUN chmod +x /usr/local/bin/totara-pecl-install

# 3.2.17RC1 is the first igbinary release that builds on PHP 8.5
RUN totara-pecl-install \
        redis-6.3.0 \
        igbinary-3.2.17RC1 \
        memcached-3.4.0 \
        imap-1.0.3 \
        excimer-1.2.6 \
        pspell-1.0.1 \
        xdebug-3.5.1 \
        pcov-1.0.12 \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis igbinary memcached imap excimer pspell xdebug pcov

# TODO: uncomment when sqlsrv supports PHP 8.5 https://github.com/microsoft/msphpsql/releases
# This also needs unixodbc-dev from the Microsoft repo installed in this stage.
# Workaround applied: https://github.com/microsoft/msphpsql/issues/1438#issuecomment-1444773949
# RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system \
#     && totara-pecl-install sqlsrv-5.12.0 pdo_sqlsrv-5.12.0 || \
#     apt-get install -y --allow-downgrades odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc=2.3.7 unixodbc-dev=2.3.7 && \
#     totara-pecl-install sqlsrv-5.12.0 pdo_sqlsrv-5.12.0

# RUN docker-php-ext-enable sqlsrv.so && docker-php-ext-enable pdo_sqlsrv.so

FROM base

ARG TIME_ZONE=Pacific/Auckland

# we need en_US locales for MSSQL connection to work
# we need en_AU locales for behat to work
# Extra locales allow testing non-English and RTL formatting
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        gnupg2 \
        cron \
        nano \
        vim \
        wget \
        openssl \
        locales \
        tzdata \
        git \
        zsh \
        zip \
        netcat-traditional \
        bc \
        ghostscript \
        graphviz \
        aspell \
        aspell-en \
        clamdscan \
        hunspell-en-us \
        hunspell-en-gb \
        xmlstarlet \
        unzip \
        openssh-client \
        less \
        procps \
        netbase \
        libfreetype6 \
        libjpeg62-turbo \
        libwebp7 \
        libpng16-16 \
        libxml2 \
        libicu72 \
        libpq5 \
        libzip4 \
        libmemcached11 \
        libldap-2.5-0 \
        libc-client2007e \
        libkrb5-3 \
        libssl3 \
        libaspell15 \
        libenchant-2-2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        msodbcsql18 \
        mssql-tools18 \
    && rm -rf /var/lib/apt/lists/* \
    && for locale in \
        en_US.UTF-8 \
        en_AU.UTF-8 \
        de_DE.UTF-8 \
        fr_FR.UTF-8 \
        es_ES.UTF-8 \
        ar_AE.UTF-8 \
        he_IL.UTF-8; \
    do \
        sed -i -e "s/# ${locale} UTF-8/${locale} UTF-8/" /etc/locale.gen; \
    done \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

COPY config/php.ini /usr/local/etc/php/
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf
COPY config/clamd.conf /etc/clamav/clamd.conf

# Source each .sh file found in the /shell/ folder, always source the default_aliases.sh file first
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && echo 'if [[ -e "/root/custom_shell/default-aliases.sh" ]]; then source "/root/custom_shell/default-aliases.sh"; fi' >> ~/.bashrc \
    && echo 'for f in /root/custom_shell/*.sh; do [[ "$f" != "/root/custom_shell/default-aliases.sh" && -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

# Have the option of using the oh my zsh shell.
RUN sh -c "$(curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && git clone --depth 1 https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && echo 'setopt +o nomatch' > ~/.zshrc \
    && echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc \
    && cat ~/.bashrc >> ~/.zshrc

COPY smoke-test.sh /usr/local/bin/totara-php-smoke-test
RUN chmod +x /usr/local/bin/totara-php-smoke-test \
    && /usr/local/bin/totara-php-smoke-test

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
