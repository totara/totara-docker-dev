FROM totara/docker-dev-php-base:latest

# This is the PHP version we want to install
ENV PHPVERSION 5.4.45

# Install php version with desired extensions
RUN phpbrew install -j $(nproc) $PHPVERSION \
    +default \
    +fpm \
    +iconv \
    +icu \
    +intl \
    +mysql \
    +pcntl \
    +pdo \
    +pgsql \
    +soap \
    +sqlite \
    +xmlrpc \
    +zlib \
    +exif \
    -- \
    --enable-gd-native-ttf \
    --with-fpm-group=www-data \
    --with-fpm-user=www-data \
    --with-freetype-dir \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-libdir=/lib/x86_64-linux-gnu \
    --with-mssql \
    --with-png-dir=/usr

RUN phpbrew clean php-$PHPVERSION

ENV PHPBREW_PHP php-$PHPVERSION

# Copy custom config file contents
RUN mkdir -p /root/.phpbrew/php/php-$PHPVERSION/etc/fpm.d
COPY config/freetds.conf /etc/freetds/freetds.conf
COPY config/php-fpm.conf /root/.phpbrew/php/php-$PHPVERSION/etc/php-fpm.conf
COPY config/php.ini /tmp/php.ini
# We just append additional php.ini vars
RUN cat /tmp/php.ini >> /root/.phpbrew/php/php-$PHPVERSION/etc/php.ini

# Set PATH to phpbrew bin folder
ENV PATH /root/.phpbrew/php/php-$PHPVERSION/bin:$PATH

EXPOSE 9000

CMD ["/bin/bash", "-c", "/root/.phpbrew/php/php-$PHPVERSION/sbin/php-fpm"]

# Source each .sh file found in the /shell/ folder
RUN echo 'for f in ~/custom_shell/*.sh; do [[ -e "$f" ]] && source "$f"; done;' >> ~/.bashrc

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
