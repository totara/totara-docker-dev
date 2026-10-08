#!/bin/sh
set -e

PRIMARY_HOST=pgsql-primary
REPLICATION_USER=replicator
PGDATA=${PGDATA:-/var/lib/postgresql/data}

if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Initializing replica..."

    until pg_isready -h "$PRIMARY_HOST" -U "$REPLICATION_USER"
    do
        sleep 2
    done

    rm -rf "$PGDATA"/*

    export PGPASSWORD=replica_password

    pg_basebackup \
        -h "$PRIMARY_HOST" \
        -U "$REPLICATION_USER" \
        -D "$PGDATA" \
        -R \
        -Fp \
        -Xs \
        -P
fi

exec docker-entrypoint.sh postgres \
    -c config_file=/etc/postgresql/postgresql.conf