# A Docker setup for local Totara development

[![Release](https://img.shields.io/github/v/release/totara/totara-docker-dev)](../../releases)
[![Release Date](https://img.shields.io/github/release-date/totara/totara-docker-dev)](../../releases)
[![Build Status](https://travis-ci.com/totara/totara-docker-dev.svg?branch=master)](https://travis-ci.com/totara/totara-docker-dev)
[![Issues](https://img.shields.io/github/issues/totara/totara-docker-dev)](../../issues)
[![License](https://img.shields.io/github/license/totara/totara-docker-dev)](../../LICENCE)

This project aims to provide an easy way to start developing for Totara by providing a Docker setup.

This setup was created and tested extensively on MacOS and Linux. It also works on Windows via WSL2.

Although this project started as a development environment for Totara Learn it can be adapted for use in any other PHP project.

<details>
<summary>Detailed container versions and build statuses</summary>

Name | Version | Dockerfile | Build
--- | --- | --- | ---
nginx | 1.20.x | [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/nginx/Dockerfile) | [![Build status Nginx](https://img.shields.io/docker/build/totara/docker-dev-nginx.svg)](https://hub.docker.com/r/totara/docker-dev-nginx/)
apache | 2.4.x | [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/apache/Dockerfile) | [![Build status Apache](https://img.shields.io/docker/build/totara/docker-dev-apache.svg)](https://hub.docker.com/r/totara/docker-dev-apache/)
mssql | 2017 | [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/mssql/Dockerfile) | [![Build status Mssql](https://img.shields.io/docker/build/totara/docker-dev-mssql.svg)](https://hub.docker.com/r/totara/docker-dev-mssql/)
php53 | 5.3 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php53/Dockerfile) | [![Build status PHP 5.3](https://img.shields.io/docker/build/totara/docker-dev-php53.svg)](https://hub.docker.com/r/totara/docker-dev-php53/)
php53-debug | 5.3 + xdebug 2.0.5 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php53-debug/Dockerfile) | [![Build status PHP 5.3 Debug](https://img.shields.io/docker/build/totara/docker-dev-php53-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php53-debug/)
php54 | 5.4 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php54/Dockerfile) | [![Build status PHP 5.4](https://img.shields.io/docker/build/totara/docker-dev-php54.svg)](https://hub.docker.com/r/totara/docker-dev-php54/)
php54-debug | 5.4 + xdebug 2.4.1 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php54-debug/Dockerfile) | [![Build status PHP 5.4 Debug](https://img.shields.io/docker/build/totara/docker-dev-php54-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php54-debug/)
php55 | 5.5 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php55/Dockerfile) | [![Build status PHP 5.5](https://img.shields.io/docker/build/totara/docker-dev-php55.svg)](https://hub.docker.com/r/totara/docker-dev-php55/)
php55-debug | 5.5 + xdebug 2.5.5 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php55-debug/Dockerfile) | [![Build status PHP 5.5 Debug](https://img.shields.io/docker/build/totara/docker-dev-php55-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php55-debug/)
php56 | 5.6 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php56/Dockerfile) | [![Build status PHP 5.6](https://img.shields.io/docker/build/totara/docker-dev-php56.svg)](https://hub.docker.com/r/totara/docker-dev-php56/)
php56-debug | 5.6 + xdebug 2.5.5 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php56-debug/Dockerfile) | [![Build status PHP 5.6 Debug](https://img.shields.io/docker/build/totara/docker-dev-php56-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php56-debug/)
php70 | 7.0 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php70/Dockerfile) | [![Build status PHP 7.0](https://img.shields.io/docker/build/totara/docker-dev-php70.svg)](https://hub.docker.com/r/totara/docker-dev-php70/)
php70-debug | 7.0 + xdebug 2.7.2 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php70-debug/Dockerfile) | [![Build status PHP 7.0 Debug](https://img.shields.io/docker/build/totara/docker-dev-php70-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php70-debug/)
php71 | 7.1 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php71/Dockerfile) | [![Build status PHP 7.1](https://img.shields.io/docker/build/totara/docker-dev-php71.svg)](https://hub.docker.com/r/totara/docker-dev-php71/)
php71-debug | 7.1 + xdebug 2.9.6 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php71-debug/Dockerfile) | [![Build status PHP 7.1 Debug](https://img.shields.io/docker/build/totara/docker-dev-php71-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php71-debug/)
php72 | 7.2 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php72/Dockerfile) | [![Build status PHP 7.2](https://img.shields.io/docker/build/totara/docker-dev-php72.svg)](https://hub.docker.com/r/totara/docker-dev-php72/)
php72-debug | 7.2 + xdebug 2.9.6 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php72-debug/Dockerfile) | [![Build status PHP 7.2 Debug](https://img.shields.io/docker/build/totara/docker-dev-php72-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php72-debug/)
php73 | 7.3 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php73/Dockerfile) | [![Build status PHP 7.3](https://img.shields.io/docker/build/totara/docker-dev-php73.svg)](https://hub.docker.com/r/totara/docker-dev-php73/)
php73-debug | 7.3 + xdebug 2.9.6 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php73-debug/Dockerfile) | [![Build status PHP 7.3 Debug](https://img.shields.io/docker/build/totara/docker-dev-php73-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php73-debug/)
php74 | 7.4 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php74/Dockerfile) | [![Build status PHP 7.4](https://img.shields.io/docker/build/totara/docker-dev-php74.svg)](https://hub.docker.com/r/totara/docker-dev-php74/)
php74-debug | 7.4 + xdebug 2.9.6 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php74-debug/Dockerfile) | [![Build status PHP 7.4 Debug](https://img.shields.io/docker/build/totara/docker-dev-php74-debug.svg)](https://hub.docker.com/r/totara/docker-dev-php74-debug/)
php80 | 8.0 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php80/Dockerfile) | [![Build status PHP 8.0](https://img.shields.io/docker/build/totara/docker-dev-php80.svg)](https://hub.docker.com/r/totara/docker-dev-php80/)
php80 | 8.1 |  [Dockerfile](https://github.com/totara/totara-docker-dev/blob/master/php/php81/Dockerfile) | [![Build status PHP 8.0](https://img.shields.io/docker/build/totara/docker-dev-php81.svg)](https://hub.docker.com/r/totara/docker-dev-php81/)
</details>

### What You Get
 * [NGINX](https://nginx.org/) as a webserver
 * [Apache](https://httpd.apache.org/) as a webserver
 * [PHP](http://php.net/) 5.3, 5.4, 5.5, 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 to test for different versions
 * [PostgreSQL](https://www.postgresql.org/) (9.3, 9.6, 10, 11, 12, 13), [MariaDB](https://mariadb.org/) (10.2, 10.4, 10.5, 10.6) and [MySQL](https://www.mysql.com/) (5.7 and 8), and [Microsoft SQL Server 2017](https://www.microsoft.com/en-us/sql-server/sql-server-2017) support
 * [NodeJS](https://nodejs.org/) for building, developing and testing frontend code
 * A [PHPUnit](https://phpunit.de/) and [Behat](http://behat.org/en/latest/) setup to run tests (including [Selenium](https://www.seleniumhq.org/))
 * A [mailcatcher](https://mailcatcher.me/) instance to view sent emails
 * [Redis](https://redis.io/) for caching and/or session handling
 * [XHProf](https://github.com/tideways/php-xhprof-extension) for profiling
 * [XDebug](https://xdebug.org/) installed, ready for debugging with your favorite IDE

## Installation & Usage

**[See the wiki](../../wiki) for detailed documentation on installation and usage.**

## Contribute

Please check out the [contributing guide](CONTRIBUTING.md) for more information on how you can help us.
