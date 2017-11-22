FROM nginx:1.13

ARG REMOTE_DATA

ENV REMOTE_DATA ${REMOTE_DATA}

COPY config/totara.conf /etc/nginx/conf.d/totara.conf

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
