#!/bin/bash

script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
project_path=$( cd "$script_path" && cd ..; pwd -P )

old_tag=$(git describe --tags)

# Big chain of commands we only want to run if the previous one was successful
echo -ne "Stopping all running containers" && \
    "$project_path"/bin/tdown &> /dev/null && \
    echo -e "...done\n\nPulling the latest code" && \
    git pull origin master --rebase && \
    echo -ne "\nPulling the latest container images - this could take a few minutes" && \
    "$project_path"/bin/tpull &> /dev/null && \
    echo -e "...done\n\n\x1B[2mSuccessfully updated to $(git describe --tags) from $old_tag\x1B[0m" && \
    echo "View the latest changes here: https://github.com/totara/totara-docker-dev/releases/latest" && \
    echo "Note: You will need to start your containers again with the tup command" && \
    return &> /dev/null || exit

# Something failed...
echo -e "\n\x1B[31mThere was an error while updating.\x1B[0m"
echo "The update can be attempted again by running the $script_path/$(basename $0) script."
