#!/bin/bash
# Default set of convenient aliases/functions for you to use inside php containers.
# You can create your own helpers by creating a new .sh/.bash file in this directory, which will also get sourced into the php containers.

# Echo a message with info colours (grey)
print_info() {
  echo -e "\x1B[2m$1\x1B[0m"
}

# Echo a message with error colours (orange)
print_error() {
  echo -e "\x1B[33m$1\x1B[0m"
}

# Echo a command and then execute it
run_cmd() {
  echo -e "\x1B[2mRunning Command: \x1B[4m$*\x1B[0m"
  $*
}

# Run a Totara command
run_totara_cmd() {
  site_root || return 1
  if [[ $1 == 'php' && -f "./server/$2" ]]; then
    shift
    run_cmd php server/$@
  else
    run_cmd $@
  fi
}

# cd into the root directory of the Totara site, or print an error message if it couldn't be found.
site_root() {
  local original_path=$(pwd)
  local current_path="$original_path"
  while [[ (! -f './config.php' || ( -f './config.php' && -f '../config.php' ))
           && "$current_path" =~ "/var/www/totara/src" && "$current_path" != "/var/www/totara/src" ]]
  do
    cd ..
    current_path=$(pwd)
  done
  if [ -f './config.php' ]; then
    if [ "$current_path" != "$original_path" ]; then
      echo -e "\x1B[2mChanged directory to \x1B[4m$current_path\x1B[0m"
    fi
    return 0
  else
    print_error "Couldn't locate a Totara site (or config.php) - are you running this from the correct directory?"
    return 1
  fi
}

# Get the major Totara/Moodle version, e.g. '13' or '2.9'
totara_version() {
  local php_code="
    \$version_file = @file_get_contents(\"./server/version.php\") ?: file_get_contents(\"./version.php\");
    \$totara_version_matches = \$moodle_version_matches = array();
    preg_match(\"/TOTARA->version[\s]*=[\s]*'([^']+)'/\", \$version_file, \$totara_version_matches);
    preg_match(\"/release[\s]*=[\s]*'([\S]+)[^']+'/\", \$version_file, \$moodle_version_matches);
    \$version = end(\$totara_version_matches) ?: end(\$moodle_version_matches);
    echo preg_replace(\"/^(\d{2}|[1-8]\.\d).+$/\", \"\$1\", \$version);
  "
  echo `php -r "$php_code"`
}

# Perform a fresh install of Totara
install() {
  site_root || return 1
  if [ -z "$1" ]; then
    # Make the site name the version of the Totara site
    local site_name="Totara `totara_version` development site"
    run_totara_cmd php admin/cli/install_database.php --adminpass=admin --adminemail=admin@example.com --agree-license --shortname=$site_name --fullname=$site_name
  else
    run_totara_cmd php admin/cli/install_database.php $@
  fi
}

# Upgrade the installation
upgrade() {
  run_totara_cmd php admin/cli/upgrade.php --non-interactive --allow-unstable $@
}

# Run cron
cron() {
  run_totara_cmd php admin/cli/cron.php $@
}

# Purge caches
purge() {
  run_totara_cmd php admin/cli/purge_caches.php $@
}

# Initialise PHPUnit
installunit() {
  # TODO: Add parallel support
  run_totara_cmd php admin/tool/phpunit/cli/init.php $@
}

# Run PhpUnit
unit() {
  # TODO: Add parallel support
  site_root || return 1
  if [ -d './test/phpunit' ]; then
    run_cmd test/phpunit/vendor/bin/phpunit --configuration='test/phpunit/phpunit.xml' --test-suffix='test.php' $@
  else
    run_cmd vendor/bin/phpunit --configuration='phpunit.xml' --test-suffix='test.php' $@
  fi
}

# Get the number of threads that is set to be used from the config.php
behat_parallel_count() {
  local php_code="
    define(\"CLI_SCRIPT\", true);
    define(\"ABORT_AFTER_CONFIG\", true);
    require(\"config.php\");
    if (isset(\$DOCKER_DEV->behat_parallel, \$DOCKER_DEV->behat_parallel_count) && \$DOCKER_DEV->behat_parallel) {
        echo(\$DOCKER_DEV->behat_parallel_count);
    } else {
        echo(0);
    }
  "
  echo `php -r "$php_code"`
}

# Initialise Behat
installbehat() {
  site_root || return 1

  # Make sure this is a supported Totara version
  if [[ $(echo "`totara_version` <= 2.5" | bc -l) == '1' ]]; then
    print_error "This script doesn't currently support Totara 2.5 or earlier."
    print_info "If you know how to make it work, please contribute a solution."
    return 1
  fi

  local parallel_count=`behat_parallel_count`
  if [[ $parallel_count != '0' || "$*" =~ "--parallel" ]]; then
    print_info "Initialising behat in parallel mode"
  else
    print_info "Initialising behat in single (debug) mode"
  fi
  if [[ $parallel_count == '0' ]]; then
    run_totara_cmd php admin/tool/behat/cli/init.php $@
  else
    run_totara_cmd php admin/tool/behat/cli/init.php --parallel=$parallel_count $@
  fi
}

# Run Behat
behat() {
  site_root || return 1

  # Make sure this is a supported Totara version
  if [[ $(echo "`totara_version` <= 2.5" | bc -l) == '1' ]]; then
    print_error "This script doesn't currently support Totara 2.5 or earlier."
    print_info "If you know how to make it work, please contribute a solution."
    return 1
  fi

  # Behat.yml variables
  local behat_dataroot_php="
    define(\"CLI_SCRIPT\", true);
    define(\"ABORT_AFTER_CONFIG\", true);
    require(\"config.php\");
    echo \$CFG->behat_dataroot;
  "
  local behat_dataroot=`php -r "$behat_dataroot_php"`
  local behat_dataroot_yml="$behat_dataroot/behat/behat.yml"
  local behat_source_yml="./behat.yml"
  if [ -d './test/behat' ]; then
    behat_dataroot_yml="$behat_dataroot/behatrun/behat/behat.yml"
    behat_source_yml="./behat_local.yml"
  fi

  # Parallel mode variables
  local parallel_mode="0"
  local parallel_count=`behat_parallel_count`
  local selenium_host="selenium-chrome-debug"
  if [[ $parallel_count != '0' || "$*" =~ "--parallel" ]]; then
    selenium_host="selenium-hub"
    parallel_mode="1"
  fi

  # Abort if behat hasn't been initialised
  if [[ ! -f "$behat_dataroot_yml" && $parallel_mode == '0' ]]; then
    print_error "Couldn't locate a behat.yml at $behat_dataroot_yml"
    print_info "Hint: Have you initialised behat? You can use \x1B[4minstallbehat"
    return 1
  fi

  # Abort if the appropriate selenium container isn't running
  if ! nc -w5 -z -v $selenium_host 4444 &> /dev/null; then
    print_error "The $selenium_host container must be running in order to run behat tests"
    [ $parallel_mode == '1' ] && print_error "(Also don't forget to create multiple selenium-chrome instances!)"
    return 1
  fi

  # If there is the new test directory (T13+), then we have to delete the old vendor directory otherwise autoloading won't work correctly
  if [[ -d './test/behat' && -f './vendor/bin/behat' ]]; then
    rm -rf './vendor'
  fi

  # We don't want the behat.yml that sits around in the site code to interfere with anything.
  # Make sure that we delete the existing one and copy the correct one.
  rm -f behat.yml
  if [[ -f "$behat_dataroot_yml" && ! -f "$behat_source_yml" ]]; then
    cp "$behat_dataroot_yml" "$behat_source_yml"
  fi

  # Run the actual command
  if [ $parallel_mode == '1' ]; then
    print_info "Running behat in parallel mode"
    if [[ ! "$*" =~ "--parallel" ]]; then
      run_totara_cmd php admin/tool/behat/cli/run.php $@
    else
      run_totara_cmd php admin/tool/behat/cli/run.php --parallel=$parallel_count $@
    fi
  else
    print_info "Running behat in single (debug) mode"
    if [ -d './test/behat' ]; then
      run_cmd test/behat/vendor/bin/behat --config "$behat_dataroot_yml" $@
    else
      run_cmd vendor/bin/behat --config "$behat_dataroot_yml" $@
    fi
  fi
}

# Create a test course
createcourse() {
  run_totara_cmd php admin/tool/generator/cli/maketestcourse.php --shortname=course --size=S $@
}

# Create a test user
createuser() {
  run_totara_cmd php totara/generator/cli/maketestuser.php $@
}
