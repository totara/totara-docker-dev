###### Build status:
 * Nginx: [![Build status Nginx](https://img.shields.io/docker/build/derschatta/totara-dev-nginx.svg)](https://hub.docker.com/r/derschatta/totara-dev-nginx/)
 * PHP 5.6: [![Build status PHP 5.6](https://img.shields.io/docker/build/derschatta/totara-dev-php56.svg)](https://hub.docker.com/r/derschatta/totara-dev-php56/)
 * PHP 7.0: [![Build status PHP 7.0](https://img.shields.io/docker/build/derschatta/totara-dev-php70.svg)](https://hub.docker.com/r/derschatta/totara-dev-php70/)
 * PHP 7.1: [![Build status PHP 7.1](https://img.shields.io/docker/build/derschatta/totara-dev-php71.svg)](https://hub.docker.com/r/derschatta/totara-dev-php71/)
 * PHP 7.2: [![Build status PHP 7.2](https://img.shields.io/docker/build/derschatta/totara-dev-php72.svg)](https://hub.docker.com/r/derschatta/totara-dev-php72/)

## A Docker setup for local Totara LMS development

This project aims to provide an easy way to start developing for Totara by providing a Docker setup.

This setup was created and tested on a MAC. It should work on Windows and Linux as well but it still needs to be tested.

### What you get:
 * NGINX as a webserver
 * PHP 5.6, 7.0, 7.1, 7.2 to test for different versions
 * PostgreSQL, MariaDB (MySQL), Microsoft SQL Server support
 * A PHPUnit and Behat setup to run tests (including Selenium)
 * A [mailcatcher](https://mailcatcher.me/) instance to inspect mails
 * [XDebug](https://xdebug.org/) installed, ready for debugging with your favorite IDE

### Requirements:
 * Totara source code: https://help.totaralearning.com/display/DEV/Getting+the+code
 * Docker: https://www.docker.com (recommend 17.09.1-ce-mac42, see warning below)
 * Docker-compose: https://docs.docker.com/compose/install (included in Docker for Mac/Windows)
 * Docker-sync: http://docker-sync.io/ (optional, for more speed on Mac and Windows)
 * At least 3.25GB of RAM for MSSQL

## Warning
Please note that there's a current [issue with docker-sync](https://github.com/EugenMayer/docker-sync/issues/517) opn Mac and Docker versions newer than [17.09.1-ce-mac42](https://docs.docker.com/docker-for-mac/release-notes/#docker-community-edition-17091-ce-mac42-2017-12-11-stable). To be on the safe side I recommend download and installing this version.

### Todo

 * Get mssql working with PHP 5.6 (driver is installed but throws error on connect)
 * Get xdebug working with PHP 7.2

### Installation:
 1. Clone the Totara source code (see requirements) 
 1. Clone this project
 1. Install docker-sync
 1. Copy the file __.env.dist__ to __.env__ and change at least the path to your local Totara source folder (LOCAL_SRC)

#### /etc/hosts
Make sure you have all the hosts in your /etc/hosts file to be able to access them via the browser.

__Example:__
```bash
127.0.0.1   localhost totara71 totara56 totara70 totara72 totara71.behat totara56.behat
```

### Run

__with docker-sync__

```bash
# fire up docker-sync as a daemon in the background
docker-sync start
```

```bash
# run in foreground (to directly see log output)
./totara-docker-sync.sh up
# run in background
./totara-docker-sync.sh up -d  
```

__without docker-sync__
```bash
./totara-docker.sh up 
# or run in background
./totara-docker.sh up -d 
```

### Build

By default prebuilt images from docker hub (https://hub.docker.com/u/derschatta/) will be used. If you want to modify any of the containers to your needs then you can rebuild them locally with the following command:

```bash
./totara-build.sh
```

### Config & Database

Make sure you have configured Totara and created the databases you need.

Modify your Totara __config.php__ and create the databases. You can connect to the databases from your host using any tools you prefer.

The host will be always __localhost__ and the ports are the default ports of the database systems.

#### Credentials

__PostgreSQL__

__host:__ pgsql
__user:__ postgresql
__pw:__ (none)

__Mysql__

__host:__ mysql
__user:__ root
__pw:__ root

__Mssql__

__host:__ mssql
__user:__ SA
__pw:__ Totara.Mssql1

To use the command line clients provided by the containers you can use the following commands:

```bash
# PostgreSQL
./totara-docker-sync.sh exec pgsql psql -U postgres
# or without docker-sync
./totara-docker.sh exec pgsql psql -U postgres

# MySQL / MariaDB
./totara-docker-sync.sh exec mariadb mysql -u root -p"root"
# or without docker-sync
./totara-docker.sh exec mariadb mysql -u root -p"root"

# Microsoft SQL Server
./totara-docker-sync.sh exec php-7.1 /opt/mssql-tools/bin/sqlcmd -S mssql -U SA -P "Totara.Mssql1"
# or without docker-sync
./totara-docker.sh exec mariadb mysql -u root -p"root"
```

Create a database schema for each Totara version you would like to develop on.

#### data directories

The nginx container automatically creates all required data folders.

They are located:

```bash
/var/www/totara/data/ver22.pgsql
/var/www/totara/data/ver22.pgsql.phpunit
/var/www/totara/data/ver22.pgsql.behat
/var/www/totara/data/ver22.mssql
/var/www/totara/data/ver22.mssql.phpunit
/var/www/totara/data/ver22.mssql.behat
/var/www/totara/data/ver22.mysql
/var/www/totara/data/ver22.mysql.phpunit
/var/www/totara/data/ver22.mysql.behat
...
/var/www/totara/data/ver11.pgsql
/var/www/totara/data/ver11.pgsql.phpunit
/var/www/totara/data/ver11.pgsql.behat
/var/www/totara/data/ver11.mssql
/var/www/totara/data/ver11.mssql.phpunit
/var/www/totara/data/ver11.mssql.behat
/var/www/totara/data/ver11.mysql
/var/www/totara/data/ver11.mysql.phpunit
/var/www/totara/data/ver11.mysql.behat
```



### Run unit tests

Make sure your config file contains the PHPUnit configuration needed and the database is ready.

Log into one of the test containers
```bash
./totara-docker-sync.sh exec php-5.6 bash
./totara-docker-sync.sh exec php-7.1 bash
# or if you need xdebug support
./totara-docker-sync.sh exec php-5.6-debug bash
./totara-docker-sync.sh exec php-7.1-debug bash
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

Make sure your config file contains the Behat configuration needed and the database is ready.

Log into one of the test containers
```bash
./totara-docker-sync.sh exec php-5.6 bash
./totara-docker-sync.sh exec php-7.1 bash
# or if you need xdebug support
./totara-docker-sync.sh exec php-5.6-debug bash
./totara-docker-sync.sh exec php-7.1-debug bash
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
# initiate the test environment (use --parallel=x if needed)
php admin/tool/behat/cli/init.php
```

To start running
```bash
# for t11
vendor/bin/behat
# for others use the command prompted after init, for example:
vendor/bin/behat --config /var/www/totara/data/ver9.pgsql.behat/behatrun/behat/behat.yml
```

### Switch between different versions

I recommend to check out each Totara Learn version in a different subfolder below the folder LOCAL_SRC defined in .env. This is just a suggestion which worked fine for me. There are different ways to handle this and at the end you need to decide yourself how to do it.

# Mailcatcher

The setup comes with mailcatcher support. Just add the following to your config and all mails will be sent to it:

```php
$CFG->smtphosts = 'mailcatcher:25';
```

Open __http://localhost:8080__ to open the mailcatcher GUI.

If needed, modify the local port in the docker-compose.yml file.

# NodeJS, NPM and grunt 

If you want to use grunt or npm you can log into the nodejs container and issue the commands there:

```bash
./totara-docker.sh run nodejs bash
# go to your source directory and
npm install
npm install grunt-cli
./node_modules/.bin/grunt
```

Or you use the shortcut bash script:

```bash
./totara-grunt.sh
./totara-grunt.sh 11
``` 
