#!/bin/bash
# You can create your own helpers by creating a new .sh file in this directory, which will also get sourced into the php containers.

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
  php -n -r "$php_code" $@
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

  version=$(php -n -r "$php_code echo \$version;")

  if [[ "$1" == "major" ]]; then
    if [[ "$version" =~ ^evergreen ]]; then
      print "evergreen"
    else
      php -n -r "$php_code echo preg_replace(\"/^(\d{2}|[1-8]\.\d|9).+$/\", \"\$1\", \$version);"
    fi
  else
    php -n -r "$php_code echo \$version;"
  fi
}

# Run composer but disable xdebug for the duration of the command
alias composer='XDEBUG_MODE=off composer'
