#!/usr/bin/env bash

# The SQL server won't start by this time, so let's gently wait for it, if it won't start in 120 sec, let's fail anyway.
timeout=$(($(date +%s) + 120))
until /opt/mssql-tools/bin/sqlcmd -H localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "select 'hello'" 2>/dev/null || [[ $(date +%s) -gt $timeout ]]; do
  echo 'SQL server is not ready yet, sleeping for 2 seconds...'
  sleep 2
done

echo "Running initial SQL statements"

# run the setup script to run initial sql statements
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d master -i /usr/config/setup.sql
