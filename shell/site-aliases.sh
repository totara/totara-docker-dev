#!/bin/bash
# You can create your own helpers by creating a new .sh file in this directory, which will also get sourced into the php containers.

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
