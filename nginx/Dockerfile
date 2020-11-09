FROM nginx:1.13

ENV REMOTE_DATA=${REMOTE_DATA}

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nano \
    openssl

COPY config/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
