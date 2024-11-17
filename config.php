<?php
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////     \//////////////////////////////////
/////////////////////////////////       \/////////////////////////////////
////////////////////////////////         \////////////////////////////////
///////////////////////////////\         /////////////////////////////////
////////////////////////////////\       //////////////////////////////////
////////////////////\        \///\     /////         /////////////////////
/////////////////////\           \//////            //////////////////////
//////////////////////\           \////            ///////////////////////
/////////////////////////\         \//          //////////////////////////
/////////////////////////////////////   //////////////////////////////////
///////////////////////////////////// ////////////////////////////////////
///////////////////////////////////// ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
/////////////////////////   Totara Docker Dev   //////////////////////////
/////////////  https://github.com/totara/totara-docker-dev  //////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//<editor-fold desc="Docker-dev specific variable setup" defaultstate="collapsed">
// phpcs:ignoreFile

// Docker-dev specific variable setup
$DOCKER_DEV = new stdClass();
$DOCKER_DEV->has_server_dir = file_exists(__DIR__ . '/server/config.php');
$DOCKER_DEV->is_multi_site = __DIR__ !== '/var/www/totara/src';
$DOCKER_DEV->site_name = $DOCKER_DEV->is_multi_site ? basename(__DIR__) : 'totara';

// Required for older versions (T12 and below) and moodle
if (!$DOCKER_DEV->has_server_dir || !isset($CFG)) {
    unset($CFG);
    global $CFG;
    $CFG = new stdClass();
}

// Get what version of Totara/Moodle is running via regex from the version.php file
// We can't include the version.php file directly as it may contain undefined constants, which results in a fatal errors in PHP 8+
$version_file = @file_get_contents(__DIR__ . '/server/version.php') ?: file_get_contents(__DIR__ . '/version.php');
$totara_version_matches = $moodle_version_matches = array();
preg_match("/TOTARA->version[\s]*=[\s]*'([^']+)'/", $version_file, $totara_version_matches);
preg_match("/release[\s]*=[\s]*'([\S]+)[^']+'/", $version_file, $moodle_version_matches);
$DOCKER_DEV->version = end($totara_version_matches) ?: end($moodle_version_matches);
$DOCKER_DEV->major_version = preg_replace("/^(\d{2}|[1-8]\.\d|9).+$/", '$1', $DOCKER_DEV->version);
unset($version_file, $totara_version_matches, $moodle_version_matches);

//</editor-fold>

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////         Main Site Database & Dataroot Configuration          //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/** PostgresSQL */
$CFG->dbhost = 'pgsql13'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
$CFG->dbtype = 'pgsql';
$CFG->dbuser = 'postgres';
$CFG->dbpass = '';

/** MySQL */
//$CFG->dbhost = 'mysql8'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
//$CFG->dbtype = 'mysqli';
//$CFG->dbuser = 'root';
//$CFG->dbpass = 'root';

/** MariaDB */
//$CFG->dbhost = 'mariadb'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
//$CFG->dbtype = 'mariadb';
//$CFG->dbuser = 'root';
//$CFG->dbpass = 'root';

/** Microsoft SQL Server */
//$CFG->dbhost = 'mssql2019'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
//$CFG->dbtype = PHP_MAJOR_VERSION >= 7 ? 'sqlsrv' : 'mssql'; // In PHP 7+ it is called 'sqlsrv' instead of 'mssql'.
//$CFG->dbuser = 'SA';
//$CFG->dbpass = 'Totara.Mssql1';

/**
 * By default, the site database name is simply the name of the subdirectory you have your site in,
 * or just 'totara' if you only have a single site. It can be accessed by using the `tdb` command.
 *
 * If you want to use a specific database for your site, set it here.
 */
$CFG->dbname = $DOCKER_DEV->site_name;
//$CFG->dbname = 'my_totara_db';

/**
 * Every table in the site database will be prefixed with this.
 * 'ttr_' and 'mdl_' are the most commonly used prefixes.
 *
 * Pro Tip: You can set the prefix to be the same as what is used for behat for extra debugging power while a scenario is paused.
 */
$CFG->prefix = 'ttr_';
//$CFG->prefix = 'mdl_';
//$CFG->prefix = 'bht_';


$CFG->directorypermissions = 02777;

/**
 * Dataroot: For storing uploaded files, temporary and cache files, and other miscellaneous files created by Totara.
 */
$CFG->dataroot = "/var/www/totara/data/{$DOCKER_DEV->site_name}.{$CFG->dbhost}";
//$CFG->dataroot = '/var/www/totara/data/totara13.pgsql13';
//$CFG->dataroot = '/var/www/totara/data/mobile.mysql';
//$CFG->dataroot = '/var/www/totara/data/engage.mssql';
if (!is_dir($CFG->dataroot)) {
    @mkdir($CFG->dataroot, $CFG->directorypermissions) && @chgrp($CFG->dataroot, 'www-data') && @chown($CFG->dataroot, 'www-data');
}

/**
 * You shouldn't really need to change these.
 */
$CFG->dblibrary = 'native';
$CFG->dboptions = array('dbpersist' => false, 'dbsocket' => false, 'dbport' => '');



//<editor-fold desc="wwwroot Configuration">

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                    wwwroot Configuration                     //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/**
 * Here we generate a dynamic wwwroot, so the site can be simultaneously accessed via different PHP versions, and externally via ngrok.
 * You shouldn't need to change this section - but if you find this needs modification to get it working,
 * then please contribute what you did back to the docker-dev repository :)
 */
// Ngrok uses a few different URLs, add if a new one is used
$ngrok_urls = [
    'ngrok.io',
    'ngrok-free.app',
    'ngrok.app',
];

// Depending on the Ngrok version its hostname is stored in different server vars
$ngrok_server_vars = [
    $_SERVER['HTTP_X_FORWARDED_HOST'] ?? '',
    $_SERVER['HTTP_X_ORIGINAL_HOST'] ?? '',
];

$ngrok_hostname = '';
foreach ($ngrok_server_vars as $server_var) {
    if (!empty($server_var) && empty($ngrok_hostname)) {
        foreach ($ngrok_urls as $ngrok_url) {
            if (strpos($server_var, $ngrok_url) !== false) {
                $ngrok_hostname = $server_var;
                break;
            }
        }
    }
}

// Turns out request came via Ngrok
if (!empty($ngrok_hostname)) {
    $_SERVER['HTTP_HOST'] = $ngrok_hostname;
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
} else if (!empty($_SERVER['HTTP_HOST']) && !empty($_SERVER['REQUEST_SCHEME'])) {
    // accessing it locally via the web
    $CFG->wwwroot = $_SERVER['REQUEST_SCHEME'] . '://';

    $hostname = $_SERVER['HTTP_HOST'];
    $hostname_parts = explode('.', $hostname);
    if (end($hostname_parts) === 'behat') {
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
    if ($DOCKER_DEV->is_multi_site) {
        $CFG->wwwroot .= '/' . $DOCKER_DEV->site_name;
    }
    if ($DOCKER_DEV->has_server_dir) {
        $CFG->wwwroot .= '/server';
    }
}
//</editor-fold>




//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                    PHPUnit Configuration                     //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/**
 * Can either use the same database as the main site for PHPUnit,
 * or a different database can be used (generally makes tests more stable)
 */
$CFG->phpunit_dbname = $CFG->dbname;
//$CFG->phpunit_dbname = 'unt_' . $CFG->dbname;
//$CFG->phpunit_dbname = 'totaraphpunit';

/**
 * You shouldn't really need to change this.
 */
$CFG->phpunit_prefix = 'phpu_';

/**
 * We use a different PHPUnit dataroot for each different version, otherwise there are warnings about the dataroot not being empty.
 */
$CFG->phpunit_dataroot = "/var/www/totara/data/{$DOCKER_DEV->site_name}.{$CFG->dbhost}.{$DOCKER_DEV->major_version}.phpunit";
if (!is_dir($CFG->phpunit_dataroot)) {
    @mkdir($CFG->phpunit_dataroot, $CFG->directorypermissions) && @chgrp($CFG->phpunit_dataroot, 'www-data') && @chown($CFG->phpunit_dataroot, 'www-data');
}



//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                     Behat Configuration                      //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/**
 * If false, then a behat config will be generated using selenium-chrome-debug, meaning you can view the pages being tested via VNC.
 * If true, then multiple behat profiles will be generated, using selenium-hub,
 * so you can run behat scenarios in parallel (faster. although you lose the ability to view it running)
 *
 * See https://github.com/totara/totara-docker-dev/wiki/Behat for more info on running behat in parallel/viewing it with VNC.
 */
$DOCKER_DEV->behat_parallel = false;

/**
 * How many behat processes to run simultaneously if behat_parallel is set to true.
 */
//$DOCKER_DEV->behat_parallel_count = 2;
$DOCKER_DEV->behat_parallel_count = 4;
//$DOCKER_DEV->behat_parallel_count = 8;

/**
 * By default, the behat database name is simply the name of the subdirectory you have your site in,
 * or just 'totara' if you only have a single site. It can be accessed by using the `tdb` command.
 *
 * If you want to use a specific database for behat, set it here.
 */
$CFG->behat_dbname = $CFG->dbname;

/**
 * You shouldn't really need to change this.
 */
$CFG->behat_prefix = 'bht_';

/**
 * Saves screenshots of what exactly failed on the last behat run.
 * You can add this directory to the .git/info/exclude file in your Totara site, so it doesn't get committed accidentally.
 */
//$CFG->behat_faildump_path = __DIR__ . '/screenshots';

/**
 * We use a different behat dataroot for each different version, otherwise as the behat.yml will need to be regenerated everytime.
 * If the same behat.yml is used across versions, then the tests won't run correctly.
 */
$CFG->behat_dataroot = "/var/www/totara/data/{$DOCKER_DEV->site_name}.{$CFG->dbhost}.{$DOCKER_DEV->major_version}.behat";
if (!is_dir($CFG->behat_dataroot)) {
    @mkdir($CFG->behat_dataroot, $CFG->directorypermissions) && @chgrp($CFG->behat_dataroot, 'www-data') && @chown($CFG->behat_dataroot, 'www-data');
}

//<editor-fold desc="Advanced behat setup" defaultstate="collapsed">
/**
 * The wwwroot for behat is the same as the host, but with '.behat' added as a suffix (so 'totara73' becomes 'totara73.behat')
 * You shouldn't really need to change this.
 */
$CFG->behat_wwwroot = 'http://totara' . PHP_MAJOR_VERSION . PHP_MINOR_VERSION . '.behat';
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
// Disable running behat in parallel if the Totara version is too old, or if there isn't enough CPU threads available.
$DOCKER_DEV->behat_parallel &= $DOCKER_DEV->major_version >= 2.9;
$DOCKER_DEV->behat_host = $DOCKER_DEV->behat_parallel ? 'selenium-hub' : 'selenium-chrome-debug';

if ($DOCKER_DEV->behat_parallel) {
    for ($i = 1; $i <= $DOCKER_DEV->behat_parallel_count; $i++) {
        $CFG->behat_parallel_run[] = array(
            'dbname' => $CFG->behat_dbname,
            'behat_prefix' => "bh{$i}_",
            'wd_host' => 'http://selenium-hub:4444/wd/hub'
        );
    }
}

if ($DOCKER_DEV->major_version > 18) {
    // Behat config for Totara 19 and higher
    $CFG->behat_profiles['default'] = array(
        'browser' => 'chrome',
        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
        'capabilities' => array(
            'extra_capabilities' => array(
                'goog:chromeOptions' => array(
                    'args' => array(
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ),
                    'excludeSwitches' => array(
                        'enable-automation'
                    ),
                    'prefs' => array(
                        'credentials_enable_service' => false,
                    ),
                )
            )
        )
    );
} else if ($DOCKER_DEV->major_version >= 10) {
    // Behat config for Totara 10+
    $CFG->behat_profiles['default'] = array(
        'browser' => 'chrome',
        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
        'capabilities' => array(
            'extra_capabilities' => array(
                'chromeOptions' => array(
                    'args' => array(
                        '--disable-infobars',
                        '--disable-background-throttling'
                    ),
                    'prefs' => array(
                        'credentials_enable_service' => false,
                    ),
                    'w3c' => false,
                ),
                'goog:chromeOptions' => array(
                    'args' => array(
                        '--disable-infobars',
                        '--disable-background-throttling',
                        '--disable-background-timer-throttling',
                        '--disable-backgrounding-occluded-windows'
                    ),
                    'prefs' => array(
                        'credentials_enable_service' => false,
                    ),
                    'w3c' => false,
                    'excludeSwitches' => array(
                        'enable-automation'
                    )
                )
            )
        )
    );
} else {
    // Behat config for Totara 9 and earlier
    $CFG->behat_config = array(
        'default' => array(
            'extensions' => array(
                'Behat\MinkExtension\Extension' => array(
                    'browser_name' => 'chrome',
                    'default_session' => 'selenium2',
                    'selenium2' => array(
                        'browser' => 'chrome',
                        'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
                        'capabilities' => array(
                            'version' => '',
                            'platform' => 'LINUX',
                        )
                    )
                )
            )
        )
    );
    if ($DOCKER_DEV->behat_parallel) {
        $CFG->behat_profiles = array(
            'default' => array(
                'browser' => 'chrome',
                'wd_host' => "http://$DOCKER_DEV->behat_host:4444/wd/hub",
                'capabilities' => array(
                    'browser' => 'chrome',
                    'browserVersion' => 'ANY',
                    'version' => '',
                    'chrome' => array(
                        'switches' => array(
                            '--disable-infobars',
                            '--disable-background-throttling'
                        ),
                        'w3c' => false
                    )
                )
            )
        );
    }
}
//</editor-fold>




//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                    Development Mode Settings                 //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

$development_mode = true;
if ($development_mode) {
    $CFG->sitetype = 'development';

    @error_reporting(E_ALL | E_STRICT);
    @ini_set('display_errors', '1');
    $CFG->debug = (E_ALL | E_STRICT & ~E_DEPRECATED);
    $CFG->debugdisplay = 1;
    $CFG->perfdebug = 15;
    define('GRAPHQL_DEVELOPMENT_MODE', true);

//    $CFG->legacyadminsettingsmenu = true;
    $CFG->debugallowscheduledtaskoverride = true;
    $CFG->preventexecpath = false;
    $CFG->mobile_device_emulator = true;

    // Useful when changing or creating language string lookups, so
    // that your changes are reflecting in the UI
    $CFG->langstringcache = false;

    // Helps to identify potentially missing or incorrectly named
    // language strings in the UI
    $CFG->debugstringids = false;

    // Allow URL query parameter to change the current system Theme for
    // the current session, handy for qualifying if changes or issues
    // exist across different Themes
    $CFG->allowthemechangeonurl = true;

    // Theme designer mode useful for individual *legacy only* Theme file
    // debugging by breaking out many Theme dependency files into separate
    // <head /> entries. This creates many requests, and significantly
    // degrades page load and readiness performance. Don't use this for
    // Tui-only development
    $CFG->themedesignermode = false;

    // Un-cache legacy-only front end dependencies
    $CFG->cachejs = false;
    $CFG->cachetemplates = false;

    // When working with YUI, you may need to disable PHP combo loading
    // of dependency files for easier debugging
    $CFG->yuicomboloading = false;
    $CFG->yuiloglevel = 'debug';

    // When you expect fresh data from GraphQL, disable the cache,
    // otherwise expect an increase to page load and readiness times
    //
    // Disabling caching of the GraphQL schema has a serious performance impact
    // thus we keep it enabled by default.
    // Either purge caches if needed or uncomment the following line if needed.
    // $CFG->cache_graphql_schema = false;

    // Tui-specific settings to turn off performance optimisations
    // during development. They do similar things to the legacy-only
    // settings, and can be turned off when not changing Tui code
    $CFG->forced_plugin_settings['totara_tui'] = array(
        'cache_js' => false,
        'cache_scss' => false,
        'development_mode' => true
    );

//    // Xhprof Profiling settings
//    $CFG->profilingenabled = true;
//    $CFG->profilingincluded = '*';
}




//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                     Extras / Miscellaneous                   //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// Redirects any emails sent by the server
$CFG->smtphosts = 'mailcatcher:25';

$CFG->passwordpolicy = false;
$CFG->tool_generator_users_password = '12345';
$CFG->upgradekey = '';

$CFG->country = 'NZ';
$CFG->defaultcity = 'Wellington'; // very windy!

//<editor-fold desc="Paths for additional binary packages" defaultstate="collapsed">
$CFG->py3path = '/usr/bin/python3';
$CFG->pathtogs = '/usr/bin/gs';
$CFG->pathtodu = '/usr/bin/du';
$CFG->aspellpath = '/usr/bin/aspell';
$CFG->pathtodot = '/usr/bin/dot';
//</editor-fold>

if ($DOCKER_DEV->major_version >= 13) {
//    $CFG->forceflavour = 'learn';
//    $CFG->forceflavour = 'learn_professional';
//    $CFG->forceflavour = 'engage';
//    $CFG->forceflavour = 'learn_engage';
//    $CFG->forceflavour = 'learn_perform';
//    $CFG->forceflavour = 'perform_engage';
    $CFG->forceflavour = 'learn_perform_engage';
} else {
    // For Totara versions earlier than 13, the enterprise flavour must be set
    $CFG->forceflavour = 'enterprise';
}













// This must be the last thing in the config.
file_exists(__DIR__ . '/lib/setup.php') && require_once __DIR__  .  '/lib/setup.php';
