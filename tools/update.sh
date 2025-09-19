#!/bin/bash

script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
project_path=$( cd "$script_path" && cd ..; pwd -P )

set -e

old_tag=$(git describe --tags)

export $(grep -E -v '^#' "$project_path/tools/.version" | xargs)


# Actual update steps
echo -ne "\033[1;35mUpdating docker dev to the latest version...\033[0m\n\n"

# Store the list of running services so they can be restarted later
echo -ne "\033[1;35mStopping all running containers...\033[0m\n"
running_services=$(tdocker ps --services --status running | xargs)
if [ -n "$running_services" ]; then
  echo "$running_services" > "$project_path/tools/.stopped_services"
fi

# Stop all containers
tdown

# Rebase on the latest master in case there are any local commits
echo -e "\n\033[1;35mPulling the latest code...\033[0m\n"
git pull origin master --rebase

source $project_path/tools/post_update.sh
