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
    clear_pcov_coverage
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

# Run PHPUnit with pcov code coverage (Totara 14+ only)
phpunit_pcov() {
  version=$(totara_version major)
  source_tag="source"
  # Totara 19+ uses PHPUnit 10, which uses the <source> tag
  # Totara 14 to 18 uses PHPUnit 9, which uses the <coverage> tag for defining areas to check coverage for
  # Totara 13 and older uses PHPUnit 8, which the <filter> and <whitelist> tags, which we don't support in this script
  if [[ "$version" =~ ^[0-9]+$ && "$version" -lt 14 ]]; then
    print_error "This script does not support Totara 13 and older"
    print_error "You can however manually configure your phpunit.xml to get code coverage working"
    return 1
  elif [[ "$version" =~ ^[0-9]+$ && "$version" -lt 19 ]]; then
    source_tag="coverage"
  fi

  if ! xmlstarlet sel -t -v "/phpunit/$source_tag" test/phpunit/phpunit.xml > /dev/null 2>&1; then
    print_error "Coverage paths not defined - run set_pcov_coverage first!"
    return 1
  fi

  output_dir="/var/www/totara/coverage-report"

  # Run with memory limit set to 8GB
  XDEBUG_MODE=off run_cmd test/phpunit/vendor/bin/phpunit \
    -dmemory_limit=8G \
    -dpcov.enabled=1 \
    -dpcov.directory="$PWD/server" \
    -dpcov.exclude='~(vendor|tests|node_modules|.git|client|.scannerwork)~' \
    -dpcov.initial.memory=1073741824 \
    -dpcov.initial.files=30000 \
    --configuration='test/phpunit/phpunit.xml' \
    --test-suffix='test.php' \
    --coverage-html "$output_dir" \
    $@ && \
    chmod o+rx -R "$output_dir" && \
    echo -e "\nGo to http://coverage-report.localhost to view the coverage report."
}
alias unitpcov='phpunit_pcov'
alias unit_pcov='phpunit_pcov'

# Add paths for pcov to cover (Totara 14+ only)
add_pcov_coverage() {
  version=$(totara_version major)
  source_tag="source"
  # Totara 19+ uses PHPUnit 10, which uses the <source> tag
  # Totara 14 to 18 uses PHPUnit 9, which uses the <coverage> tag for defining areas to check coverage for
  # Totara 13 and older uses PHPUnit 8, which the <filter> and <whitelist> tags, which we don't support in this script
  if [[ "$version" =~ ^[0-9]+$ && "$version" -lt 14 ]]; then
    print_error "This script does not support Totara 13 and older"
    print_error "You can however manually configure your phpunit.xml to get code coverage working"
    return 1
  elif [[ "$version" =~ ^[0-9]+$ && "$version" -lt 19 ]]; then
    source_tag="coverage"
  fi

  if [[ -z "$@" ]]; then
    print_error "No files or directories specified"
    return 1
  fi

  # Build xmlstarlet arguments dynamically based on input files/directories
  xml_args=()
  for arg in "$@"; do
    if [[ -d "$arg" ]]; then
      xml_args+=(
        -s "/phpunit/$source_tag/include[last()]" -t elem -n directory -v "$PWD/$arg"
        -i "/phpunit/$source_tag/include/directory[last()]" -t attr -n suffix -v ".php"
      )
    elif [[ -f "$arg" ]]; then
      xml_args+=(
        -s "/phpunit/$source_tag/include[last()]" -t elem -n file -v "$PWD/$arg"
      )
    else
      print_error "$arg is not a valid file or directory"
      return 1
    fi
  done

  # Check if a <coverage> tag already exists and only add if not present
  if ! xmlstarlet sel -t -v "/phpunit/coverage" test/phpunit/phpunit.xml > /dev/null 2>&1; then
    xmlstarlet ed -L \
      -s "/phpunit" -t elem -n "coverage" -v "" \
      -s "/phpunit/coverage" -t elem -n report -v "" \
      -s "/phpunit/coverage/report" -t elem -n html -v "" \
      -i "/phpunit/coverage/report/html" -t attr -n outputDirectory -v "/var/www/totara/coverage-report" \
      test/phpunit/phpunit.xml
  fi

  # Check if <source> or <coverage> element exists and create it if needed
  if ! xmlstarlet sel -t -v "/phpunit/$source_tag" test/phpunit/phpunit.xml &>/dev/null; then
    xmlstarlet ed -L -s "/phpunit" -t elem -n "$source_tag" -v "" test/phpunit/phpunit.xml
  fi
  # Check if <include> element exists and create it if needed
  if ! xmlstarlet sel -t -v "/phpunit/$source_tag/include" test/phpunit/phpunit.xml &>/dev/null; then
    xmlstarlet ed -L -s "/phpunit/$source_tag" -t elem -n "include" -v "" test/phpunit/phpunit.xml
  fi
  # Add the coverage paths
  xmlstarlet ed -L \
    ${xml_args[@]} \
    test/phpunit/phpunit.xml

  echo "Added coverage paths to test/phpunit/phpunit.xml"
}
alias add_coverage='add_pcov_coverage'

# Reset paths for pcov to cover
clear_pcov_coverage() {
  site_root || return 1
  if [ ! -f test/phpunit/phpunit.xml ]; then
    return
  fi
  if xmlstarlet sel -t -v "/phpunit/coverage | /phpunit/source" test/phpunit/phpunit.xml > /dev/null 2>&1; then
    xmlstarlet ed -L -d "/phpunit/coverage"  -d "/phpunit/source" test/phpunit/phpunit.xml
    print_info "Cleared coverage entries from test/phpunit/phpunit.xml"
  fi
}
alias clear_coverage='clear_pcov_coverage'

# Clear existing coverage settings and add new ones
set_pcov_coverage() {
  clear_pcov_coverage
  add_pcov_coverage "$@"
}
alias set_coverage='set_pcov_coverage'
