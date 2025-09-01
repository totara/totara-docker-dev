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

// Firstly, set up some docker-dev specific variables (must be at the start!)
// See https://github.com/totara/totara-docker-dev/blob/master/php/includes/config-before.php
$DOCKER_DEV = new stdClass();
$DOCKER_DEV->dir = __DIR__;
require '/var/www/totara/includes/config-before.php';


//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////         Main Site Database & Dataroot Configuration          //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/** PostgresSQL */
$CFG->dbhost = 'pgsql16'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
$CFG->dbtype = 'pgsql';
$CFG->dbuser = 'postgres';
$CFG->dbpass = '';

/** MySQL */
//$CFG->dbhost = 'mysql84'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
//$CFG->dbtype = 'mysqli';
//$CFG->dbuser = 'root';
//$CFG->dbpass = 'root';

/** MariaDB */
//$CFG->dbhost = 'mariadb1108'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
//$CFG->dbtype = 'mariadb';
//$CFG->dbuser = 'root';
//$CFG->dbpass = 'root';

/** Microsoft SQL Server */
//$CFG->dbhost = 'mssql2022'; // See https://github.com/totara/totara-docker-dev/wiki/Database%20Credentials for other versions
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

    if (PHP_MAJOR_VERSION >= 8) {
        @error_reporting(E_ALL);
        $CFG->debug = E_ALL;
    } else {
        // STRICT error level is only used before PHP 8
        // avoid string search for constant name in server/index.php
        $estrict = constant('E_' . 'STRICT');
        @error_reporting(E_ALL | $estrict);
        $CFG->debug = (E_ALL | $estrict);
    }
    @ini_set('display_errors', '1');
    $CFG->debugdisplay = 1;
    $CFG->perfdebug = 15;
    define('GRAPHQL_DEVELOPMENT_MODE', true);

    // $CFG->legacyadminsettingsmenu = true;
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

    // External API debug mode
    $CFG->forced_plugin_settings['totara_api'] = array(
        'response_debug' => 2, // 0 = None, 1 = Normal, 2 = Developer
    );

    // Xhprof Profiling settings
    // $CFG->profilingenabled = true;
    // $CFG->profilingincluded = '*';
}



//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                     Extras / Miscellaneous                   //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

$CFG->passwordpolicy = false;
$CFG->tool_generator_users_password = '12345';
$CFG->upgradekey = '';

$CFG->country = 'NZ';
$CFG->defaultcity = 'Wellington'; // very windy!

if ($DOCKER_DEV->major_version >= 13) {
    // $CFG->forceflavour = 'learn';
    // $CFG->forceflavour = 'learn_professional';
    // $CFG->forceflavour = 'engage';
    // $CFG->forceflavour = 'learn_engage';
    // $CFG->forceflavour = 'learn_perform';
    // $CFG->forceflavour = 'perform_engage';
    $CFG->forceflavour = 'learn_perform_engage';
} else {
    // For Totara versions earlier than 13, the enterprise flavour must be set
    $CFG->forceflavour = 'enterprise';
}



//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////                                                              //////
//////                      Your Custom Config                      //////
//////                                                              //////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////



// Add config specific to your site / development env here!












// Finally, include docker-dev specific config (must be at the end!)
// See https://github.com/totara/totara-docker-dev/blob/master/php/includes/config-after.php
require '/var/www/totara/includes/config-after.php';
// DO NOT ADD ANYTHING AFTER THIS LINE