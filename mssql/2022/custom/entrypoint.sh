#!/usr/bin/env bash

# start SQL Server, start the script to create the DB and import the data, start the app
/opt/mssql/bin/sqlservr & /usr/config/setup.sh & tail -f /dev/null