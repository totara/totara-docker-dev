#!/bin/bash

if [[ -z "$LOCAL_SRC" ]]; then
    script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
    project_path=$( cd "$script_path" && cd ..; pwd -P )
    set -a; source "$project_path/.env"; set +a
fi

# We don't want to update it if:
# * Automatic updating is disabled in .env
# * The current user doesn't have write permissions nor owns the docker-dev directory
# * The current branch is not master
# * Git isn't available
if [[ "$AUTO_UPDATE" == "0" ]] \
   || [[ ! -w "$project_path" || ! -O "$project_path" ]] \
   || ! command -v git &>/dev/null \
   || [[ $(git rev-parse --abbrev-ref HEAD) != "master" ]]; then
    return &> /dev/null || exit
fi

# Check when we last checked for updates.
current_time=$(date +%s)

update_time() {
    echo "last_update_time=$current_time" > "$project_path/tools/.update"
}

if [[ ! -f "$project_path/tools/.update" ]]; then
    # Haven't updated before, can skip for now.
    update_time
    return &> /dev/null || exit
fi

export $(grep -E -v '^#' "$project_path/tools/.update" | xargs)
if [[ -z "$last_update_time" ]]; then
    # Haven't updated before, can skip for now.
    update_time
    return &> /dev/null || exit
fi

seven_days_in_seconds=604800
update_time_difference=$(expr $current_time - $last_update_time)
if [ "$update_time_difference" -lt "$seven_days_in_seconds" ]; then
    # Last updated less than 7 days ago, can skip for now.
    return &> /dev/null || exit
fi

# No matter what, something will be done now, so update the last updated timestamp.
update_time

# If the current head is the same as the latest remote master then we don't need to update.
current_version_hash=`git rev-parse HEAD`
latest_version_hash=($( git ls-remote --heads https://github.com/totara/totara-docker-dev.git refs/heads/master))
latest_version_hash=${latest_version_hash[0]}
if [[ "$current_version_hash" == "$latest_version_hash" ]]; then
    # There aren't any updates. Will check again in 7 days.
    return &> /dev/null || exit
fi

echo "\033[1;35mThere is a newer version of totara-docker-dev available!\033[0m"
echo "Updating will stop all running containers, pulling new container images and then restart your services."
read -p "Would you like to update? [Y/n] " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    source "$project_path/tools/update.sh"
    # Containers have been stopped, so should quit out and not continue running whatever the command was.
    exit
fi

# Now we continue on and run the command that they originally wanted to run.
