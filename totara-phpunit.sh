#!/bin/bash

export $(egrep -v '^#' .env | xargs)

PHPCONTAINER=$1

# You can specify a subdirectory as first parameter to this script if needed
MYPATH=$REMOTE_SRC/$2

SETUP=$3

if [ $SETUP = "init" ]
then
    echo "Init unit tests..."
    ./totara-docker.sh exec $PHPCONTAINER sh -c "cd $MYPATH && php admin/tool/phpunit/cli/init.php"
else
    echo "Running unit tests..."
    ./totara-docker.sh exec $PHPCONTAINER sh -c "cd $MYPATH && vendor/bin/phpunit $3"
fi