FROM nginx:1.20-alpine

ENV REMOTE_DATA=${REMOTE_DATA}

RUN apk add --no-cache --update \
    nano \
    openssl \
    gettext

COPY config/default.conf /etc/nginx/conf.d/default.conf
COPY config/server.conf /etc/nginx/totara-server.conf
COPY config/local-server.conf /etc/nginx/totara-local-server.conf
COPY config/remote-server.conf /etc/nginx/totara-remote-server.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
