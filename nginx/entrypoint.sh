#!/bin/bash

echo "Using data folder: $REMOTE_DATA"

cd $REMOTE_DATA || return;

echo "Creating data folders..."

versions=("22" "24" "25" "26" "27" "29" "9" "10" "11" "12" "13" "14")

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
if [ ! -f "/etc/nginx/ssl/domain.crt" ]
then
    mkdir -p /etc/nginx/ssl
    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 3650 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=CA/L=SF/O=Docker-demo/CN=totara" \
        -keyout /etc/nginx/ssl/domain.key \
        -out /etc/nginx/ssl/domain.crt
fi

# Replace the remote src variable in the nginx configuration with
# the one defined in the environment variables
envsubst '$REMOTE_SRC' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
# fire up nginx
nginx -g 'daemon off;'
