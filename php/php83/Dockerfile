FROM php:8.3-fpm-bookworm AS base

# apt does not retry failed downloads, so a single timed out .deb from the Debian CDN fails
# the whole build. Older suites go cold in the CDN more often, but any suite can time out.
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries

# Extensions are compiled here, only the built .so files and their ini files are copied into the final image
FROM base AS build

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libicu-dev \
        libpq-dev \
        libzip-dev \
        libmemcached-dev \
        libldap2-dev \
        libpspell-dev \
        gnupg2 \
        git \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        unixodbc-dev

RUN docker-php-ext-install -j$(nproc) \
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
        pspell \
    && docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg \
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

RUN totara-pecl-install \
        redis-6.3.0 \
        igbinary-3.2.16 \
        memcached-3.4.0 \
        excimer-1.2.6 \
        xdebug-3.4.0 \
        pcov-1.0.12 \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis igbinary memcached excimer xdebug pcov

# Workaround applied: https://github.com/microsoft/msphpsql/issues/1438#issuecomment-1444773949
RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system \
    && totara-pecl-install sqlsrv-5.12.0 pdo_sqlsrv-5.12.0 || \
    apt-get install -y --allow-downgrades odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc=2.3.7 unixodbc-dev=2.3.7 && \
    totara-pecl-install sqlsrv-5.12.0 pdo_sqlsrv-5.12.0

RUN docker-php-ext-enable sqlsrv.so && docker-php-ext-enable pdo_sqlsrv.so

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
        xmlstarlet \
        unzip \
        openssh-client \
        less \
        procps \
        netbase \
        libfreetype6 \
        libjpeg62-turbo \
        libpng16-16 \
        libxml2 \
        libicu72 \
        libpq5 \
        libzip4 \
        libmemcached11 \
        libldap-2.5-0 \
        libaspell15 \
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

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

COPY config/php.ini /usr/local/etc/php/
COPY config/fpm.conf /usr/local/etc/php-fpm.d/zz-totara.conf

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
