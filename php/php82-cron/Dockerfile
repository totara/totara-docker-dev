FROM totara/docker-dev-php82:latest

RUN apt-get update && apt-get install -y cron

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
