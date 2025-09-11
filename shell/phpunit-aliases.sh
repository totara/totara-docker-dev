#!/bin/bash
# You can create your own helpers by creating a new .sh file in this directory, which will also get sourced into the php containers.

# Initialise PHPUnit
install_phpunit() {
  args=${*/parallel/processes}
  if [[ "$args" =~ "processes" ]]; then
    run_totara_cmd php admin/tool/phpunit/cli/parallel_init.php $args
  else
    run_totara_cmd php admin/tool/phpunit/cli/init.php $@
  fi
}
alias installunit='install_phpunit'

# Run PhpUnit
phpunit() {
  site_root || return 1
  args=${*/parallel/processes}
  if [[ -d './test/phpunit' ]]; then
    if [[ "$args" =~ "processes" ]]; then
      run_totara_cmd php admin/tool/phpunit/cli/parallel_run.php --configuration='test/phpunit/phpunit.xml' $args
    else
      run_cmd test/phpunit/vendor/bin/phpunit --configuration='test/phpunit/phpunit.xml' --test-suffix='test.php' $@
    fi
  elif [[ "$args" =~ "processes" ]]; then
    run_totara_cmd php admin/tool/phpunit/cli/parallel_run.php --configuration='phpunit.xml' $args
  else
    run_cmd vendor/bin/phpunit --configuration='phpunit.xml' --test-suffix='test.php' $@
  fi
}
alias unit='phpunit'
