FROM totara/docker-dev-php54:latest

RUN phpbrew ext install xdebug 2.4.1

# Fix ini to use zendextension not extension
RUN sed -i "s|extension=xdebug.so|zendextension=xdebug.so|" /root/.phpbrew/php/php-$PHPVERSION/var/db/xdebug.ini \
