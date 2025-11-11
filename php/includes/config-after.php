<?php

// This file contains docker-dev specific config settings that will be consistent across all docker dev sites.
// Changes that are made here impact all docker dev sites.



// DB Options

/**
 * You shouldn't really need to change these.
 */
$CFG->dblibrary = 'native';
$CFG->dboptions = ['dbpersist' => false, 'dbsocket' => false, 'dbport' => ''];

/**
 * If using the docker dev SQL Server images, the servers are configured with self issued SSL certs
 * They can be ignored/trusted for dev environments only.
 */
if ($CFG->dbtype == 'sqlsrv' || $CFG->dbtype == 'mssql') {
    $CFG->dboptions['trustservercertificate'] = true;
    $CFG->dboptions['encrypt'] = true;
}


// Dynamic Dataroot Creation 
if (!is_dir($CFG->dataroot)) {
    @mkdir($CFG->dataroot, $CFG->directorypermissions) && @chgrp($CFG->dataroot, 'www-data') && @chown($CFG->dataroot, 'www-data');
}



// PHPUnit Configuration

/**
 * We use a different PHPUnit dataroot for each different version, otherwise there are warnings about the dataroot not being empty.
 */
$CFG->phpunit_dataroot = "/var/www/totara/data/{$DOCKER_DEV->site_name}.{$CFG->dbhost}.{$DOCKER_DEV->major_version}.phpunit";
if (!is_dir($CFG->phpunit_dataroot)) {
    @mkdir($CFG->phpunit_dataroot, $CFG->directorypermissions) && @chgrp($CFG->phpunit_dataroot, 'www-data') && @chown($CFG->phpunit_dataroot, 'www-data');
}


// Behat Configuration


/**
 * We use a different behat dataroot for each different version, otherwise as the behat.yml will need to be regenerated everytime.
 * If the same behat.yml is used across versions, then the tests won't run correctly.
 */
$CFG->behat_dataroot = "/var/www/totara/data/{$DOCKER_DEV->site_name}.{$CFG->dbhost}.{$DOCKER_DEV->major_version}.behat";
if (!is_dir($CFG->behat_dataroot)) {
    @mkdir($CFG->behat_dataroot, $CFG->directorypermissions) && @chgrp($CFG->behat_dataroot, 'www-data') && @chown($CFG->behat_dataroot, 'www-data');
}

/**
 * The wwwroot for behat is the same as the host, but with '.behat' added as a suffix (so 'totara73' becomes 'totara73.behat')
 * You shouldn't really need to change this.
 */
$CFG->behat_wwwroot = 'http://totara' . PHP_MAJOR_VERSION . PHP_MINOR_VERSION . '.behat';
if ($DOCKER_DEV->xdebug_enabled) {
    $CFG->behat_wwwroot .= '.debug';
}
if ($DOCKER_DEV->is_multi_site) {
    $CFG->behat_wwwroot .= '/' . $DOCKER_DEV->site_name;
}
if ($DOCKER_DEV->has_server_dir) {
    $CFG->behat_wwwroot .= '/server';
}

/**
 * This is where the behat setup get a bit complicated - here we generate the behat config that supports multiple different Totara versions.
 * You shouldn't need to change this section - but if you find this needs modification to get it working,
 * then please contribute what you did back to the docker-dev repository :)
 */

if ($DOCKER_DEV->major_version < 2.9) {
    // Disable running behat in parallel if the Totara version is too old, or if there isn't enough CPU threads available.
    $DOCKER_DEV->behat_parallel = false;
}

if ($DOCKER_DEV->behat_parallel) {
    $DOCKER_DEV->behat_host = 'selenium-hub';

    for ($i = 1; $i <= $DOCKER_DEV->behat_parallel_count; $i++) {
        $CFG->behat_parallel_run[] = [
            'dbname' => $CFG->behat_dbname,
            'behat_prefix' => "bh{$i}_",
            'wd_host' => 'http://selenium-hub:4444/wd/hub'
        ];
    }
} else if ($DOCKER_DEV->major_version > 18) {
    $DOCKER_DEV->behat_host = 'selenium-chrome-debug';
} else {
    $DOCKER_DEV->behat_host = 'selenium-chrome-debug-legacy';
}

if ($DOCKER_DEV->major_version > 18) {
    // Behat profile needed for Totara 19+
    $CFG->behat_profiles['default'] = [
        'browser' => 'chrome',
        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
        'capabilities' => [
            'extra_capabilities' => [
                'goog:chromeOptions' => [
                    'args' => [
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ],
                    'excludeSwitches' => [
                        'enable-automation'
                    ],
                    'prefs' => [
                        'credentials_enable_service' => false,
                    ],
                ]
            ]
        ]
    ];
    $CFG->behat_profiles['chrome_latest'] = [
        'browser' => 'chrome',
        'wd_host' => "http://selenium-chrome-debug-latest:4444/wd/hub",
        'capabilities' => [
            'extra_capabilities' => [
                'goog:chromeOptions' => [
                    'args' => [
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ],
                    'excludeSwitches' => [
                        'enable-automation'
                    ],
                    'prefs' => [
                        'credentials_enable_service' => false,
                    ],
                ]
            ]
        ]
    ];
    $CFG->behat_profiles['edge'] = [
        'browser' => 'edge',
        'wd_host' => "http://selenium-edge-debug:4444/wd/hub",
        'capabilities' => [
            'extra_capabilities' => [
                'ms:edgeOptions' => [
                    'args' => [
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ],
                    'excludeSwitches' => [
                        'enable-automation'
                    ],
                    'prefs' => [
                        'credentials_enable_service' => false,
                    ],
                ]
            ]
        ]
    ];
    $CFG->behat_profiles['firefox'] = [
        'browser' => 'firefox',
        'wd_host' => "http://selenium-firefox-debug:4444/wd/hub",
        'capabilities' => [
            'extra_capabilities' => [],
        ]
    ];
} else if ($DOCKER_DEV->major_version >= 10) {
    // Behat config for Totara 10+
    $CFG->behat_profiles['default'] = [
        'browser' => 'chrome',
        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
        'capabilities' => [
            'extra_capabilities' => [
                'chromeOptions' => [
                    'args' => [
                        '--disable-infobars',
                        '--disable-background-throttling'
                    ],
                    'prefs' => [
                        'credentials_enable_service' => false,
                    ],
                    'w3c' => false,
                ],
                'goog:chromeOptions' => [
                    'args' => [
                        '--disable-infobars',
                        '--disable-background-throttling',
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ],
                    'prefs' => [
                        'credentials_enable_service' => false,
                    ],
                    'w3c' => false,
                    'excludeSwitches' => [
                        'enable-automation'
                    ]
                ]
            ]
        ]
    ];
} else {
    // Behat config for Totara 9 and earlier
    $CFG->behat_config = [
        'default' => [
            'extensions' => [
                'Behat\MinkExtension\Extension' => [
                    'browser_name' => 'chrome',
                    'default_session' => 'selenium2',
                    'selenium2' => [
                        'browser' => 'chrome',
                        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
                        'capabilities' => [
                            'version' => '',
                            'platform' => 'LINUX',
                        ]
                    ]
                ]
            ]
        ]
    ];
    if ($DOCKER_DEV->behat_parallel) {
        $CFG->behat_profiles = [
            'default' => [
                'browser' => 'chrome',
                'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
                'capabilities' => [
                    'browser' => 'chrome',
                    'browserVersion' => 'ANY',
                    'version' => '',
                    'chrome' => [
                        'switches' => [
                            '--disable-infobars',
                            '--disable-background-throttling'
                        ],
                        'w3c' => false
                    ]
                ]
            ]
        ];
    }
}



// wwwroot setup

// Matches URL with ngrok.app, ngrok-free.app or ngrok.pizza
$ngrok_hostname_regex = '/\b(?:ngrok-free\.app|ngrok\.app|ngrok\.pizza)\b/';
if (!empty($_SERVER['HTTP_X_FORWARDED_HOST']) && preg_match($ngrok_hostname_regex, $_SERVER['HTTP_X_FORWARDED_HOST'])) {
    // Request came via ngrok
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
} else if (!empty($_SERVER['HTTP_X_ORIGINAL_HOST']) && preg_match($ngrok_hostname_regex, $_SERVER['HTTP_X_ORIGINAL_HOST'])) {
    // Request came via ngrok
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_ORIGINAL_HOST'];
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
} else if (!empty($_SERVER['HTTP_HOST']) && !empty($_SERVER['REQUEST_SCHEME'])) {
    // accessing it locally via the web
    $CFG->wwwroot = $_SERVER['REQUEST_SCHEME'] . '://';

    $hostname = $_SERVER['HTTP_HOST'];
    $hostname_parts = explode('.', $hostname);
    if (end($hostname_parts) === 'behat' || prev($hostname_parts) === 'behat') {
        // redirect if using the behat URL
        $hostname = str_replace('.behat', '', $hostname);
    }
    $CFG->wwwroot .= $hostname;

    if ($DOCKER_DEV->is_multi_site && strpos($hostname, $DOCKER_DEV->site_name) === false) {
        $CFG->wwwroot .= '/' . $DOCKER_DEV->site_name;
        if ($DOCKER_DEV->has_server_dir) {
            $CFG->wwwroot .= '/server';
        }
    }
} else {
    // accessing it via CLI
    $CFG->wwwroot = 'http://totara' . PHP_MAJOR_VERSION . PHP_MINOR_VERSION;
    if ($DOCKER_DEV->xdebug_enabled) {
        $CFG->wwwroot .= '.debug';
    }
    if ($DOCKER_DEV->is_multi_site) {
        $CFG->wwwroot .= '/' . $DOCKER_DEV->site_name;
    }
    if ($DOCKER_DEV->has_server_dir) {
        $CFG->wwwroot .= '/server';
    }
}


// Redirect emails sent by the server to the maildev container
$CFG->smtphosts = 'maildev:1025';


// Paths to binaries
$CFG->py3path = '/usr/bin/python3';
$CFG->pathtogs = '/usr/bin/gs';
$CFG->pathtodu = '/usr/bin/du';
$CFG->aspellpath = '/usr/bin/aspell';
$CFG->pathtodot = '/usr/bin/dot';
