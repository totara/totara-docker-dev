# [![Totara](https://raw.githubusercontent.com/wiki/totara/totara-docker-dev/images/totara-small.png)](https://totaralearning.com) _Totara Docker Dev:_ A Totara Development Environment

[![Release](https://img.shields.io/github/v/release/totara/totara-docker-dev)](../../releases)
[![Release Date](https://img.shields.io/github/release-date/totara/totara-docker-dev)](../../releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/totara/totara-docker-dev/release.yml)](../../actions/workflows/release.yml)
[![Issues](https://img.shields.io/github/issues/totara/totara-docker-dev)](../../issues)
[![License](https://img.shields.io/github/license/totara/totara-docker-dev)](../../LICENCE)

This project aims to provide an easy way to start developing for Totara by providing a Docker setup.

This setup was created and tested extensively on MacOS and Linux. It also works on Windows via WSL2.

Although this project started as a development environment for Totara Learn it can be adapted for use in any other PHP project.

### What You Get
 * [NGINX](https://nginx.org/) as a webserver
 * [Apache](https://httpd.apache.org/) as a webserver
 * [PHP](http://php.net/) 5.3, 5.4, 5.5, 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4 to test for different versions
 * [PostgreSQL](https://www.postgresql.org/) (9.3, 9.6, 10, 11, 12, 13, 14, 15, 16), 
 * [MariaDB](https://mariadb.org/) (10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.11, 11.4), 
 * [MySQL](https://www.mysql.com/) (5.7, 8.0, 8.4), 
 * Microsoft SQL Server ([2017](https://www.microsoft.com/en-us/sql-server/sql-server-2017), [2019](https://www.microsoft.com/en-us/sql-server/sql-server-2019), [2022](https://www.microsoft.com/en-us/sql-server/sql-server-2022))
 * [NodeJS](https://nodejs.org/) for building, developing and testing frontend code
 * A [PHPUnit](https://phpunit.de/) and [Behat](http://behat.org/en/latest/) setup to run tests (including [Selenium](https://www.seleniumhq.org/))
 * A [MailDev](https://github.com/maildev/maildev?tab=readme-ov-file#maildev) instance to view sent emails
 * [Redis](https://redis.io/) for caching and/or session handling
 * [XHProf](https://github.com/tideways/php-xhprof-extension) for profiling
 * [XDebug](https://xdebug.org/) installed, ready for debugging with your favorite IDE
 * A [Python](https://www.python.org/) instance to run the Totara Machine Learning service
 * Optimised for [Apple Silicon](../../wiki/Apple-Silicon-support)

## Installation & Usage

**[See the wiki](../../wiki) for detailed documentation on installation and usage.**

## Contribute

Please check out the [contributing guide](CONTRIBUTING.md) for more information on how you can help us.
