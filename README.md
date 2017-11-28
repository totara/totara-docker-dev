## A Docker setup for local Totara LMS development

This project aims to provide a easy way to start developing for Totara by providing a Docker setup.

This setup was created and tested on a MAC. It should work on Windows and Linux as well but it still needs to be tested.

### What you get:
 * NGINX as a webserver
 * PHP 5.6, 7.0, 7.1, 7.2RC to test for different versions
 * PostgreSQL, MariaDB (MySQL), Microsoft SQL Server support
 * A PHPUnit and Behat setup to run tests (including Selenium)

### Requirements:
 * Totara source code: https://help.totaralearning.com/display/DEV/Getting+the+code
 * Docker: https://www.docker.com
 * Docker-compose: https://docs.docker.com/compose/install (included in Docker for Mac/Windows)
 * Docker-sync: http://docker-sync.io/ (optional, for more speed on Mac and Windows)
 * At least 3.25GB of RAM for MSSQL

### Todo

 * Get mssql working with PHP 5.6 (driver is installed but throws error on connect)
 * Get mssql working with PHP 7.2RC (dependency problem in mssql extension)

### Installation:
 1. Clone the Totara source code (see requirements) 
 1. Clone this project
 1. Install docker-sync
 1. Copy the file __.env.dist__ to __.env__ and change at least the path to your local Totara source folder (LOCAL_SRC)
 1. In your totara-docker-env folder run:

__with docker-sync__
```bash
# use helper file provided
./totara-docker.sh build

# or call it directly
docker-compose -f docker-compose.yml -f docker-compose-dev.yml build
```

__without docker-sync__
```bash
docker-compose build
```

#### /etc/hosts
Make sure you have all the hosts in your /etc/hosts file to be able to access them via the browser.

__Example:__
```bash
127.0.0.1   localhost totara.71.local totara.56.local totara.70.local totara.72.local totara.71.local.behat
```

You can change the hostnames in the nginx configuration file (/nginx/config/totara.conf) to your needs.

### Run

__with docker-sync__

```bash
# 1. fire up docker-sync as a daemon in the background
docker-sync start
# or alternatively once in the foreground
docker-sync-stack start
```

```bash
# use helper file provided
./totara-docker.sh up
# run in background
./totara-docker.sh up -d 

# or call it directly
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up
# run in background
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d 
```

__without docker-sync__
```bash
docker-compose up
```

Now make sure you have configured Totara and created the databases you need.

### Config & Database

Modify your Totara __config.php__ and create the databases. You can connect to the databases from your host using any tools you prefer.

The host will be always __localhost__ and the ports are the default ports of the database systems.

To use the command line clients provided by the containers you can use the following commands:

```bash
# PostgreSQL
docker exec -ti docker_pgsql_1 psql -U postgres
# MySQL / MariaDB
docker exec -ti docker_mariadb_1 mysql -u root -p"root"
# Microsoft SQL Server
docker exec -ti docker_php-7.1_1 /opt/mssql-tools/bin/sqlcmd -S mssql -U SA -P "Totara.Mssql1"
```

Create a database schema for each Totara version you would like to develop on.

### Run unit tests

Make sure your config file contains the PHPUnit configuration needed and the database is ready.

Log into one of the test containers
```bash
./totara-docker.sh run php-5.6-test bash
./totara-docker.sh run php-7.1-test bash
```

Go to the project folder
```bash
# replace version
cd /var/www/totara/src/[version]
```

First time run the init script to initiate the unit tests
```bash
# in the project folder
php composer.phar install
# initiate the test environment
php admin/tool/phpunit/cli/init.php
```

To start running
```bash
vendor/bin/phpunit
```

### Run behat tests

wip

### Switch between different versions

wip