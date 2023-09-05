FROM httpd:2.4-alpine

RUN apk add --no-cache --update \
    nano \
    openssl \
    gettext

COPY config/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY config/server.conf /usr/local/apache2/conf.d/server.conf
COPY config/local-server.conf /usr/local/apache2/conf.d/local-server.conf
COPY config/remote-server.conf /usr/local/apache2/conf.d/remote-server.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
