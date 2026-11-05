# Changelog

## [1.28.2](https://github.com/totara/totara-docker-dev/compare/v1.28.1...v1.28.2) (2026-11-05)


### Bug Fixes

* Upgrade Debian packages in the php73, php74 and php80 images ([bff4b4f](https://github.com/totara/totara-docker-dev/commit/bff4b4f7404b46439ed639fff46239081905e02f))


### Build & CI

* Add misconfiguration scanning to the repo scan ([55c6c76](https://github.com/totara/totara-docker-dev/commit/55c6c7694f9d14b75024ee3024ce12dabb9bda18))
* Default the Trivy pin in the setup action and retry the download ([fd30209](https://github.com/totara/totara-docker-dev/commit/fd30209c31154cb1d8aaf29de58cb8724a088857))
* Ignore kernel header and unfixable findings in the image scans ([0907498](https://github.com/totara/totara-docker-dev/commit/0907498ee06ca28584eb16fb3bc065bfc958b626))
* Replace trivy-action with a pinned Trivy install and cache ([e0a392b](https://github.com/totara/totara-docker-dev/commit/e0a392bb081faad49939ba4b17b6b22366724a18))
* Scan images after each release and the repo weekly ([fc2c863](https://github.com/totara/totara-docker-dev/commit/fc2c8635c6ed29f418f2a83ebd147712453ec61d))
* Scan images from the build workflows instead of workflow_run ([6173e0d](https://github.com/totara/totara-docker-dev/commit/6173e0d83cc57530afeb6f8257256a1c3c1a7ea5))
* Stop image scans from running side by side ([0396535](https://github.com/totara/totara-docker-dev/commit/0396535c7efd8b80a506aa30bea2b9da28e0c112))
* Validate scan inputs and pin the SARIF category per image ([89e7c03](https://github.com/totara/totara-docker-dev/commit/89e7c034e214069a6537034ec878976a54e2f670))

## [1.28.1](https://github.com/totara/totara-docker-dev/compare/v1.28.0...v1.28.1) (2026-11-02)


### Bug Fixes

* Distrust the eMudhra and Sectigo AAA root CAs in the PHP images ([912c971](https://github.com/totara/totara-docker-dev/commit/912c971578919a45ed61a324822b7fa22e6bccea))

## [1.28.0](https://github.com/totara/totara-docker-dev/compare/v1.27.1...v1.28.0) (2026-10-28)


### Features

* Pull every image in use and show progress in tpull ([b5407ba](https://github.com/totara/totara-docker-dev/commit/b5407bad9362ded229b9d39626a5ab27c6d4cff6))
* Remove the machine learning service ([e2ac9c4](https://github.com/totara/totara-docker-dev/commit/e2ac9c4663576300a13a8fb14c1f66e411676191))


### Bug Fixes

* Apply Debian security updates when building the PHP images ([fa420d6](https://github.com/totara/totara-docker-dev/commit/fa420d62067c65fb347669dd8f1a04e9691aa0ae))
* Skip locally built services when tpull refreshes images ([60666b8](https://github.com/totara/totara-docker-dev/commit/60666b8d814f55eb7a735992d4578c689fc67e6e))


### Build & CI

* Build each image platform on a native runner instead of QEMU ([c5d6dd3](https://github.com/totara/totara-docker-dev/commit/c5d6dd3f2ba3bc8245e3b3f71a25c211c34da43c))
* Check every platform digest before tagging the image ([812c573](https://github.com/totara/totara-docker-dev/commit/812c573d9470b1d387d1033d301b19b6cb930f3a))
* Match image platforms by os and architecture in the up-to-date check ([4d3a44d](https://github.com/totara/totara-docker-dev/commit/4d3a44dde8f47fda19c2bf97f2515474af5b91df))
* Show ci commits in the changelog ([66f3c4e](https://github.com/totara/totara-docker-dev/commit/66f3c4ef397f375edc7ae23bac3f3ea47f6de1b5))

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
