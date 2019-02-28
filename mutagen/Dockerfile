FROM debian:stretch-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y wget

RUN cd /root/ && wget --show-progress https://github.com/havoc-io/mutagen/releases/download/v0.8.0/mutagen_linux_arm64_v0.8.0.tar.gz \
    && tar -xzvf mutagen_linux_arm64_v0.8.0.tar.gz

COPY entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh

CMD /root/entrypoint.sh