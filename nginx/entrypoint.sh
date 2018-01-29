#!/bin/bash

echo "Using data folder: $REMOTE_DATA"

cd $REMOTE_DATA

echo "Creating data folders..."

versions=("22" "24" "25" "26" "27" "29" "9" "10" "11")

for i in "${versions[@]}"
do
   :
   echo "Creating folders for version $i"
   mkdir -p ver$i.mssql ver$i.mysql ver$i.pgsql
   chown -R www-data:www-data ver$i.mssql ver$i.mysql ver$i.pgsql
   chmod g+s ver$i.mssql ver$i.mysql ver$i.pgsql

   mkdir -p ver$i.mssql.phpunit ver$i.mysql.phpunit ver$i.pgsql.phpunit ver$i.pgsql.behat
   chown -R www-data:www-data ver$i.pgsql.behat
   chmod g+s ver$i.pgsql.behat
done

echo "done"

# fire up nginx
nginx -g 'daemon off;'
