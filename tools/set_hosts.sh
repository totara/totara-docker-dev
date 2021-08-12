#!/bin/bash

script_path=$( cd "$(dirname $0)" || exit; pwd -P )
project_path=$( cd "$script_path" && cd ..; pwd -P )
export $(grep -E -v '^#' "$project_path/.env" | xargs)

# Get all the possible php hosts from the docker compose yml file
php_versions=($(cat "$project_path/compose/php.yml" | sed -r -n 's/.*\php-([0-9]).([0-9])[^:]*:/\1\2/p' | uniq | sort))

# Get the sub sites that we should also add host entries for
sites=()
if [[ ! -f "$LOCAL_SRC/config.php" && ! -f "$LOCAL_SRC/version.php" ]]; then
    # We only want to get the visible directories located in the site directory
    sites=($(find "$LOCAL_SRC" -maxdepth 1 -not -path '*/.*' -type d -exec basename {} \;))
fi

host_ip="127.0.0.1"

hosts="$host_ip"

for php_version in "${php_versions[@]}"; do
    hosts+=" totara${php_version} totara${php_version}.behat totara${php_version}.debug"
done

for site in "${sites[@]}"; do
    hosts+="\n${host_ip}"
    for php_version in "${php_versions[@]}"; do
        hosts+=" ${site}.totara${php_version} ${site}.totara${php_version}.behat ${site}.totara${php_version}.debug"
    done
done

# Remove existing hosts, and creates a backup of the hosts file in case something goes wrong
sudo sed -i.bak '/totara-docker-dev/d' /etc/hosts \
    && sudo rm /etc/hosts.bak \
    && sudo sed -i.bak -r '/totara[0-9]{2}/d' /etc/hosts \
    && sudo rm /etc/hosts.bak

# Add the hosts
hosts="# totara-docker-dev start\n$hosts\n# totara-docker-dev end"
sudo -- sh -c -e "echo '$hosts' >> /etc/hosts";

echo "Your /etc/hosts file has been updated";
if [ -n "$sites" ]; then
    echo "Hosts have been added for the following sites: ${sites[@]}"
fi
