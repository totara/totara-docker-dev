# mssql-agent-fts-ha-tools
# Maintainers: Microsoft Corporation (twright-msft on GitHub)
# GitRepo: https://github.com/Microsoft/mssql-docker

FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

RUN mkdir -p /usr/config
WORKDIR /usr/config

COPY 2022/custom /usr/config

RUN chmod +x /usr/config/*.sh && \
    chown mssql:mssql /usr/config/*.sh

USER mssql

# Run SQL Server process
ENTRYPOINT ["/usr/config/entrypoint.sh"]
