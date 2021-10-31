#!/bin/bash
# Default set of convenient aliases/functions for you to use inside php containers.
# You can create your own helpers by creating a new .sh/.bash file in this directory, which will also get sourced into the php containers.

# Echo a message with info colours (grey)
print_info() {
  echo -e "\x1B[2m$1\x1B[0m"
}

# Echo a message with error colours (orange)
print_error() {
  echo -e "\x1B[33m$1\x1B[0m" >&2
  return 1
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

# Is this directory the root of a Totara/Moodle site?
is_site_root() {
  [[ -f './config.php' && -f './version.php' ]] && return 0 || return 1
}

# cd into the root directory of the Totara site, or print an error message if it couldn't be found.
site_root() {
  local original_path=$(pwd)
  local current_path="$original_path"
  while [[ ! -f './config.php' || -f './config.php' && -f '../config.php' ]] &&
        [[ "$current_path" =~ "/var/www/totara/src" && "$current_path" != "/var/www/totara/src" ]]
  do
    cd ..
    current_path=$(pwd)
  done
  if is_site_root; then
    if [[ "$current_path" != "$original_path" ]]; then
      echo -e "\x1B[2mChanged directory to \x1B[4m$current_path\x1B[0m" >&2
    fi
    return 0
  else
    print_error "Couldn't locate a Totara site (or config.php) - are you running this from the correct directory?"
    return 1
  fi
}

# Output config.php variables
config_var() {
  site_root || return 1
  local php_code="
    define(\"CLI_SCRIPT\", true);
    define(\"ABORT_AFTER_CONFIG\", true);
    require(\"config.php\");
    array_shift(\$argv);
    \$output = array();
    foreach (\$argv as \$arg) {
        if (isset(\$CFG->\$arg)) {
            \$output[] = \$CFG->\$arg;
        } else {
            fwrite(fopen('php://stderr', 'w'), '\$CFG->' . \$arg . ' was not found.' . PHP_EOL);
            exit(1);
        }
    }
    fwrite(fopen('php://stdout', 'w'), implode(' ', \$output));
  "
  php -r "$php_code" $@
}

# Get the Totara/Moodle version, e.g. '14.2dev' or '2.9.3'
# Specify 'major' as the first argument to get just the major version, e.g. '14' or '2.9'
totara_version() {
  site_root || return 1
  local php_code="
    \$version_file = file_get_contents(\"./version.php\");
    \$totara_version_matches = \$moodle_version_matches = array();
    preg_match(\"/TOTARA->version[\s]*=[\s]*'([^']+)'/\", \$version_file, \$totara_version_matches);
    preg_match(\"/release[\s]*=[\s]*'([\S]+)[^']+'/\", \$version_file, \$moodle_version_matches);
    \$version = end(\$totara_version_matches) ?: end(\$moodle_version_matches);
  "
  if [[ "$1" == "major" ]]; then
    php -r "$php_code echo preg_replace(\"/^(\d{2}|[1-8]\.\d|9).+$/\", \"\$1\", \$version);"
  else
    php -r "$php_code echo \$version;"
  fi
}

# Perform a fresh install of Totara
install() {
  site_root || return 1
  if [[ -z "$1" ]]; then
    # Make the site name the version of the Totara site
    local site_name="Totara $(totara_version major) development site"
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
install_phpunit() {
  # TODO: Add parallel support
  run_totara_cmd php admin/tool/phpunit/cli/init.php $@
}
alias installunit='install_phpunit'

# Run PhpUnit
phpunit() {
  # TODO: Add parallel support
  site_root || return 1
  if [[ -d './test/phpunit' ]]; then
    run_cmd test/phpunit/vendor/bin/phpunit --configuration='test/phpunit/phpunit.xml' --test-suffix='test.php' $@
  else
    run_cmd vendor/bin/phpunit --configuration='phpunit.xml' --test-suffix='test.php' $@
  fi
}
alias unit='phpunit'

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
  php -r "$php_code"
}

# Initialise Behat
install_behat() {
  site_root || return 1

  # Make sure this is a supported Totara version
  if [[ $(echo "$(totara_version major) <= 2.5" | bc -l) == '1' ]]; then
    print_error "This script doesn't currently support Totara 2.5 or earlier."
    print_info "If you know how to make it work, please contribute a solution."
    return 1
  fi

  local parallel_count=$(behat_parallel_count)
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
alias installbehat='install_behat'

# Run Behat
behat() {
  site_root || return 1

  # Make sure this is a supported Totara version
  if [[ $(echo "$(totara_version major) <= 2.5" | bc -l) == '1' ]]; then
    print_error "This script doesn't currently support Totara 2.5 or earlier."
    print_info "If you know how to make it work, please contribute a solution."
    return 1
  fi

  # Behat.yml variables
  local behat_dataroot=$(config_var behat_dataroot)
  local behat_dataroot_yml="$behat_dataroot/behat/behat.yml"
  local behat_source_yml="./behat.yml"
  if [[ -f './server/version.php' ]]; then
    behat_dataroot_yml="$behat_dataroot/behatrun/behat/behat.yml"
    behat_source_yml="./behat_local.yml"
  fi

  # Parallel mode variables
  local parallel_mode="0"
  local parallel_count=$(behat_parallel_count)
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
    [[ $parallel_mode == '1' ]] && print_error "(Also don't forget to create multiple selenium-chrome instances!)"
    return 1
  fi

  # If there is the new test directory (T13+), then we have to delete the old vendor directory otherwise autoloading won't work correctly
  if [[ -f './server/version.php' && -f './vendor/bin/behat' ]]; then
    rm -rf './vendor'
  fi

  # We don't want the behat.yml that sits around in the site code to interfere with anything.
  # Make sure that we delete the existing one and copy the correct one.
  rm -f behat.yml
  if [[ -f "$behat_dataroot_yml" && ! -f "$behat_source_yml" ]]; then
    cp "$behat_dataroot_yml" "$behat_source_yml"
  fi

  # convert relative path to absolute ones
  local args=()
  for arg in "$@"; do
    if [[ -f "$PWD/$arg" ]]; then
        args+=("$PWD/$arg")
    else
        args+=("$arg")
    fi
  done

  # Run the actual command
  if [[ $parallel_mode == '1' ]]; then
    print_info "Running behat in parallel mode"
    if [[ ! "$*" =~ "--parallel" ]]; then
      run_totara_cmd php admin/tool/behat/cli/run.php "${args[@]}"
    else
      run_totara_cmd php admin/tool/behat/cli/run.php --parallel=$parallel_count "${args[@]}"
    fi
  else
    print_info "Running behat in single (debug) mode"
    if [[ -f './server/version.php' ]]; then
      run_cmd test/behat/vendor/bin/behat --config "$behat_dataroot_yml" "${args[@]}"
    else
      run_cmd vendor/bin/behat --config "$behat_dataroot_yml" "${args[@]}"
    fi
  fi
}

# Create a test course
create_course() {
  run_totara_cmd php admin/tool/generator/cli/maketestcourse.php --shortname=course --size=S $@
}
alias createcourse='create_course'

# Create a test user
create_user() {
  run_totara_cmd php totara/generator/cli/maketestuser.php $@
}
alias createuser='create_user'
