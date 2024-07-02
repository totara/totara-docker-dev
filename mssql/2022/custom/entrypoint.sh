#!/usr/bin/env bash

# Start the script to create the DB and import the data, start the app
/usr/config/setup.sh &

# Start the server
/opt/mssql/bin/sqlservr