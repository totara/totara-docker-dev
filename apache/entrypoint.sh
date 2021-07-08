#!/bin/bash

echo "Using data folder: $REMOTE_DATA"

cd $REMOTE_DATA || return;

echo "Creating data folders..."

versions=("22" "24" "25" "26" "27" "29" "9" "10" "11" "12" "13" "14" "15")

for i in "${versions[@]}"
do
   :
   echo "Creating folders for version $i"
   mkdir -p "ver$i.mssql" "ver$i.mysql" "ver$i.pgsql"
   chown -R www-data:www-data ver$i.mssql ver$i.mysql ver$i.pgsql
   chmod g+s "ver$i.mssql" "ver$i.mysql" "ver$i.pgsql"

   mkdir -p "ver$i.mssql.phpunit" "ver$i.mysql.phpunit" "ver$i.pgsql.phpunit" "ver$i.pgsql.behat"
   chown -R www-data:www-data ver$i.pgsql.behat
   chmod g+s "ver$i.pgsql.behat"
done

echo "done"

# if there's no ssl certificate yet create it
if [ ! -f "/usr/local/apache2/conf/server.crt" ]; then
    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 3650 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=CA/L=SF/O=Docker-demo/CN=totara" \
        -keyout /usr/local/apache2/conf/server.key \
        -out /usr/local/apache2/conf/server.crt
fi

# Replace the remote src variable in the nginx configuration with
# the one defined in the environment variables
cp /usr/local/apache2/conf.d/server.conf /tmp/temp.conf
envsubst '$REMOTE_SRC' < /tmp/temp.conf > /usr/local/apache2/conf.d/server.conf
rm /tmp/temp.conf

httpd -D "FOREGROUND" -k start
