<?php
/**
 * This is a helper script that gets the PHP container with the latest version that the Totara site supports,
 * and starts it if it isn't already running.
 */

$docker_dev_root = dirname(dirname(__DIR__));

if (empty($argv[1])) {
    fwrite(fopen('php://stderr', 'wb'), "Must specify the totara site path as the first argument" . PHP_EOL);
    exit(1);
}
$site_path = $argv[1];
$silent = !empty($argv[2]) && strpos($argv[2], 'silent') !== false;

// Gets the ID & Name of the latest PHP container that can be used for this Totara version
$php_container_ids = trim((string) shell_exec('docker ps -af "name=^totara_php" --format "{{.ID}}"'));
$php_container_ids = !empty($php_container_ids) ? preg_split('/\s+/',$php_container_ids) : array();
$php_container_names = trim((string) shell_exec('docker ps -aaf "name=^totara_php" --format "{{.Names}}"'));
$php_container_names = !empty($php_container_names) ? preg_split('/\s+/', $php_container_names) : array();
$php_containers_running = array_combine($php_container_ids, $php_container_names);
asort($php_containers_running);
$php_containers_running = array_filter(array_reverse($php_containers_running), function ($container_name) {
    return strpos($container_name, 'debug') === false && strpos($container_name, 'cron') === false;
});

// Get all the possible containers that could be started
$php_containers_matches = array();
preg_match_all("/php-([0-9]\.[0-9])[^:]*:/", file_get_contents("$docker_dev_root/compose/php.yml"), $php_containers_matches);
if (empty($php_containers_matches)) {
    fwrite(fopen('php://stderr', 'wb'), "Fatal regex error" . PHP_EOL);
    exit(1);
}
$php_containers_available = array_unique($php_containers_matches[1]);
asort($php_containers_available);
$php_containers_available = array_reverse($php_containers_available);

// Get the versions to use from the site composer.json (if it exists)
$matches = array();
$composer_json = json_decode(@file_get_contents("$site_path/composer.json"));
if (isset($composer_json->require->php)) {
    // Extract the PHP versions we can use for Totara
    $versions = $composer_json->require->php;
    preg_match_all('/(\D+)(\d\.\d)\S*\s(\D+)(\d\.\d)\S*/', $versions, $matches);
    $min_comparator = $matches[1][0];
    $min_version = $matches[2][0];
    $max_comparator = $matches[3][0];
    $max_version = $matches[4][0];
} else {
    // There isn't a composer json - this means moodle is running.
    $min_comparator = '>=';
    $min_version = '7.1';
    $max_comparator = '<=';
    $max_version = '7.4';
}

// See if any supported containers are currently running - it's faster to just use what is available than upping a new container.
foreach ($php_containers_running as $container_id => $container_name) {
    $matches = array();
    preg_match_all('/php(\d)(\d)/', $container_name, $matches);
    $container_version = $matches[1][0] . '.' . $matches[2][0];
    if (version_compare($container_version, $min_version, $min_comparator) && version_compare($container_version, $max_version, $max_comparator)) {
        if (!$silent) {
            echo 'php-' . $container_version . ' ' . $container_id . ' ' . $container_version;
        }
        exit(0);
    }
}

// No supported containers are currently running, so let's just start the container for the latest supported version of php.
foreach ($php_containers_available as $container_version) {
    if (version_compare($container_version, $min_version, $min_comparator) && version_compare($container_version, $max_version, $max_comparator)) {
        shell_exec('tup php-' . $container_version);
        $container_id = shell_exec('docker ps -aqf "name=^totara_php' . str_replace('.', '', $container_version) . '$"');

        if (!$silent) {
            echo 'php-' . $container_version . ' ' . $container_id . ' ' . $container_version;
        }
        exit(0);
    }
}

exit(1);
