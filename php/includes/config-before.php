<?php

// This file contains setup for the $DOCKER_DEV variable, used to build other config settings.


// Docker-dev specific variable setup
$DOCKER_DEV->has_server_dir = file_exists($DOCKER_DEV->dir . '/server/config.php');
$DOCKER_DEV->is_multi_site = $DOCKER_DEV->dir !== '/var/www/totara/src';
$DOCKER_DEV->site_name = $DOCKER_DEV->is_multi_site ? basename($DOCKER_DEV->dir) : 'totara';


// Required for older versions (T12 and below) and moodle
if (!$DOCKER_DEV->has_server_dir || !isset($CFG)) {
    unset($CFG);
    global $CFG;
    $CFG = new stdClass();
}


// Get what version of Totara/Moodle is running via regex from the version.php file
// We can't include the version.php file directly as it may contain undefined constants, which results in a fatal errors in PHP 8+
$version_file = @file_get_contents($DOCKER_DEV->dir . '/server/version.php') ?: file_get_contents($DOCKER_DEV->dir . '/version.php');
$totara_version_matches = $moodle_version_matches = [];
preg_match("/TOTARA->version[\s]*=[\s]*'([^']+)'/", $version_file, $totara_version_matches);
preg_match("/release[\s]*=[\s]*'([\S]+)[^']+'/", $version_file, $moodle_version_matches);
$DOCKER_DEV->version = end($totara_version_matches) ?: end($moodle_version_matches);
$DOCKER_DEV->major_version = preg_replace("/^(\d{2}|[1-8]\.\d|9).+$/", '$1', $DOCKER_DEV->version);
unset($version_file, $totara_version_matches, $moodle_version_matches);
