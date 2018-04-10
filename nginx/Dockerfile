FROM nginx:1.13

ENV REMOTE_DATA=${REMOTE_DATA}

COPY config/totara.conf /etc/nginx/conf.d/default.conf
COPY config/server.conf /etc/nginx/totara-server.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
