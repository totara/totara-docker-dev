FROM totara/docker-dev-php53:latest

RUN phpbrew ext install xdebug 2.0.5

# Fix ini to use zendextension not extension
RUN sed -i "s|extension=xdebug.so|zendextension=xdebug.so|" /root/.phpbrew/php/php-$PHPVERSION/var/db/xdebug.ini \
