# Changelog

## [1.27.1](https://github.com/totara/totara-docker-dev/compare/v1.27.0...v1.27.1) (2026-10-22)


### Bug Fixes

* bump php 8.5 dockerfile to the latest version ([4c9a923](https://github.com/totara/totara-docker-dev/commit/4c9a9235a31c535f7c64e2f91d8e1e1e08f440fc))

## [1.27.0](https://github.com/totara/totara-docker-dev/compare/v1.26.1...v1.27.0) (2026-10-21)


### Features

* Add additional PHP locales ([957a9ee](https://github.com/totara/totara-docker-dev/commit/957a9ee1ac042c920e148970e1e90bfef60b8b9d))
* Add ClamAV container with automatic config wiring for PHP 8.4 and 8.5 ([d67e858](https://github.com/totara/totara-docker-dev/commit/d67e858aa7e9b452599ae7bba59cc9d8868115b9))
* Add Enchant to PHP 8.4/8.5 containers ([0e72eb7](https://github.com/totara/totara-docker-dev/commit/0e72eb7c56d9367cdf9fb4956f1aa29cb97fa51b))
* Add tcomposer command ([04f17a6](https://github.com/totara/totara-docker-dev/commit/04f17a67256dd5cf3c26ccc5623f36c857b77111))
* Add tnode command ([d771db2](https://github.com/totara/totara-docker-dev/commit/d771db2c9adc481c4306ffa11bf63f96f83589d1))
* Preserve .npmrc across nodejs runs ([7b741b4](https://github.com/totara/totara-docker-dev/commit/7b741b4a555ee2b07f53b5ea9c0675f644a43270))
* Update to Node 26 ([7eebaab](https://github.com/totara/totara-docker-dev/commit/7eebaaba9dd1ceb0f6e127c3abb6fba183dd046a))
* Update to the latest release tag instead of master ([449eabd](https://github.com/totara/totara-docker-dev/commit/449eabd11a7d703359f9fb1f4d411e8f6d648c18))


### Bug Fixes

* Download pecl packages with curl retries ([f4b585d](https://github.com/totara/totara-docker-dev/commit/f4b585dda81d515b47db34b5b44d143ea00cd08b))
* Force LF line endings for shell scripts ([3ecfdc5](https://github.com/totara/totara-docker-dev/commit/3ecfdc55714d662129421703d1c2198be06e4acf))
* Install sqlsrv pecl packages with curl retries ([75e2a74](https://github.com/totara/totara-docker-dev/commit/75e2a74a6dd725af293f5f9ac8d7946e875a41a3))
* Pass arguments through tdocker without re-parsing them ([298f423](https://github.com/totara/totara-docker-dev/commit/298f423f395f3e38ce99d4a24619535655a25d58))
* Pin PECL extension versions and retry failed downloads ([68ed45b](https://github.com/totara/totara-docker-dev/commit/68ed45babc59052968b5b5c6db04040a7b7be922))
* Point bullseye-security apt source at archive.debian.org for PHP 7.3, 7.4 and 8.0 ([dabb85b](https://github.com/totara/totara-docker-dev/commit/dabb85ba56e0dc5988734e9030b7fa3d7dcd3fb0))
* Prevent Xdebug from triggering when running composer ([c8106c3](https://github.com/totara/totara-docker-dev/commit/c8106c3d30cde499f01f81f22c433d60654a5f6c))
* Remove no-op debug option from tcomposer ([064c384](https://github.com/totara/totara-docker-dev/commit/064c3844a35bb8def2fe2aeebf131ad28869270d))
* Retry only the pecl download, not the build ([47bbccf](https://github.com/totara/totara-docker-dev/commit/47bbccf761374a3992fd80434d1ec204be0c22cb))

## Changelog

Releases after 1.26.1 are recorded here.
For earlier releases see https://github.com/totara/totara-docker-dev/releases
