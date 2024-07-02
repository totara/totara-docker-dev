# mssql-agent-fts-ha-tools
# Maintainers: Microsoft Corporation (twright-msft on GitHub)
# GitRepo: https://github.com/Microsoft/mssql-docker

FROM --platform=linux/amd64 ubuntu:22.04

# Install Server FTS & HA
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y \
        gnupg && \
    apt-get install -y \
        curl \
        locales \
        apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | tee /etc/apt/sources.list.d/mssql-server-2022.list && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y \
        mssql-server \
        mssql-server-ha \
        mssql-server-fts \
        mssql-tools18 \
        unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Copy the config across
RUN mkdir -p /usr/config
COPY 2022/custom /usr/config

RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/setup.sh

WORKDIR /usr/config

# Run SQL Server process
ENTRYPOINT ["./entrypoint.sh"]