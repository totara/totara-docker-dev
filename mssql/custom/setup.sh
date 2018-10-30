#!/usr/bin/env bash

# wait for the SQL Server to come up
sleep 20s

echo "Running initial SQL statements"

# run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -d master -i /custom/setup.sql