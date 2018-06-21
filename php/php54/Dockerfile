FROM debian:wheezy

ARG TIME_ZONE=Pacific/Auckland

ENV DEBIAN_FRONTEND noninteractive

COPY config/php.ini /etc/php5/conf.d/99-php.ini
COPY config/fpm.conf /etc/php5/fpm/pool.d/zz-totara.conf

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
    build-essential

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php5-cli \
    php5-fpm \
    php5-intl \
    php5-pgsql \
    php5-mysql \
    php5-gd \
    php5-mssql \
    php5-curl \
    php5-xmlrpc \
    php-pear \
    php5-dev

COPY config/freetds.conf /etc/freetds/freetds.conf

RUN sed -i 's/error_log = \/var\/log\/php5-fpm.log/error_log = \/proc\/self\/fd\/2/g' /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 9000/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/pm.max_children = 5/pm.max_children = 16/g' /etc/php5/fpm/pool.d/www.conf

RUN echo ${TIME_ZONE} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

EXPOSE 9000

CMD ["php5-fpm", "-F"]