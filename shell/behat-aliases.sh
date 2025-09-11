#!/bin/bash
# You can create your own helpers by creating a new .sh file in this directory, which will also get sourced into the php containers.

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

  version=$(totara_version major)

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

  version=$(totara_version major)

  # Behat.yml variables
  local behat_dataroot=$(config_var behat_dataroot)
  local behat_dataroot_yml="$behat_dataroot/behat/behat.yml"
  local behat_source_yml="./behat.yml"
  if [[ -f './server/version.php' ]]; then
    behat_dataroot_yml="$behat_dataroot/behatrun/behat/behat.yml"
    behat_source_yml="./behat_local.yml"
  fi

  local args=()

  # convert relative path to absolute ones
  for arg in "$@"; do
    if [[ -f "$PWD/$arg" ]]; then
        args+=("$PWD/$arg")
    else
        args+=("$arg")
    fi
  done

  # Parallel mode variables
  local parallel_mode="0"
  local parallel_count=$(behat_parallel_count)
  local selenium_host="selenium-chrome-debug"
  if [[ $parallel_count != '0' || "$*" =~ "--parallel" ]]; then
    selenium_host="selenium-hub"
    parallel_mode="1"
  elif [[ "$version" =~ ^[0-9]+$ && "$version" -lt 19 ]]; then
    # Totara 18 and older requires selenium-chrome-debug-legacy
    selenium_host="selenium-chrome-debug-legacy"
  elif [[ "$*" =~ "--profile=firefox" || "$*" =~ "-p firefox" ]]; then
    selenium_host="selenium-firefox-debug"
  elif [[ "$*" =~ "--profile=edge" || "$*" =~ "-p edge" ]]; then
    selenium_host="selenium-edge-debug"
  elif [[ "$*" =~ "--profile=chrome_latest" || "$*" =~ "-p chrome_latest" ]]; then
    selenium_host="selenium-chrome-debug-latest"
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

# Outputs the error logs for the last behat run
behat_logs() {
  local behat_dataroot=$(config_var behat_dataroot)
  local parallel_count=$(behat_parallel_count)
  if [[ $parallel_count == '0' ]]; then
    cat $(config_var behat_dataroot)/behatrun_error.log
  else
    for ((i=1; i <= parallel_count; i++)); do
      cat "$(config_var behat_dataroot)/behatrun${i}_error.log"
    done
  fi
}
alias behatlogs='behat_logs'
alias behatlog='behat_logs'
