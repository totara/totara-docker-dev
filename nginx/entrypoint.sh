#!/usr/bin/env bash

cd ${REMOTE_DATA}

# version 9

mkdir -p ver9.mssql
mkdir -p ver9.mysql
mkdir -p ver9.pgsql

chown -R www-data:www-data ver9.mssql
chown -R www-data:www-data ver9.mysql
chown -R www-data:www-data ver9.pgsql

mkdir -p ver9.mssql.phpunit
mkdir -p ver9.mysql.phpunit
mkdir -p ver9.pgsql.phpunit

mkdir -p ver9.pgsql.behat
chown -R www-data:www-data ver9.pgsql.behat

# version 10

mkdir -p ver10.mssql
mkdir -p ver10.mysql
mkdir -p ver10.pgsql

chown -R www-data:www-data ver10.mssql
chown -R www-data:www-data ver10.mysql
chown -R www-data:www-data ver10.pgsql

mkdir -p ver10.mssql.phpunit
mkdir -p ver10.mysql.phpunit
mkdir -p ver10.pgsql.phpunit

mkdir -p ver10.pgsql.behat
chown -R www-data:www-data ver10.pgsql.behat

# version 11

mkdir -p ver11.mssql
mkdir -p ver11.mysql
mkdir -p ver11.pgsql

chown -R www-data:www-data ver11.mssql
chown -R www-data:www-data ver11.mysql
chown -R www-data:www-data ver11.pgsql

mkdir -p ver11.mssql.phpunit
mkdir -p ver11.mysql.phpunit
mkdir -p ver11.pgsql.phpunit

mkdir -p ver11.pgsql.behat
chown -R www-data:www-data ver11.pgsql.behat

# fire up nginx
nginx -g 'daemon off;'
