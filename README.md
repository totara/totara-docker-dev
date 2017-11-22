## A Docker setup for local Totara LMS development

This project aims to provide a easy way to start developing for Totara by providing a Docker setup.

This setup was created and tested on a MAC. It should work on Windows and Linux as well but it still needs to be tested.

#### What you get:
 * NGINX as a webserver
 * PHP 5.6, 7.0, 7.1, 7.2RC to test for different versions
 * PostgreSQL, MySQL, MSSQL support
 * A PHPUnit and Behat setup to run tests (including Selenium)

#### Requirements:
 * Totara source code: https://help.totaralearning.com/display/DEV/Getting+the+code
 * Docker: https://www.docker.com
 * Docker-compose: https://docs.docker.com/compose/install (included in Docker for Mac/Windows)
 * Docker-sync: http://docker-sync.io/ (optional, for more speed on Mac and Windows)

#### Installation:
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

##### /etc/hosts
Make sure you have all the hosts in your /etc/hosts file to be able to access them via the browser.

__Example:__
```bash
127.0.0.1   localhost totara.71.local totara.56.local totara.70.local totara.72.local totara.71.local.behat
```

You can change the hostnames in the nginx configuration file (/nginx/config/totara.conf) to your needs.

#### Run

__with docker-sync__
```bash
# fire up docker-sync as a daemon in the background
docker-sync start
# or alternatively once in the foreground
docker-sync-stack start

# use helper file provided
./totara-docker.sh up

# or call it directly
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up
```

__without docker-sync__
```bash
docker-compose up
```

##### Config & Database

Modify your Totara __config.php__ and create the databases. You can connect to the databases from your host using any tools you prefer.

To use the command line clients provided by the containers you can use the following commands:

```bash
docker exec -ti docker_pgsql_1 psql -U postgres
docker exec -ti docker_mariadb_1 mysql -u root -p"root"
docker exec -ti docker_php-7.1_1 /opt/mssql-tools/bin/sqlcmd -S mssql -U SA -P "Totara.Mssql1"
```

#### Run unit tests


#### Run behat tests

