#!/bin/bash

script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
project_path=$( cd "$script_path" && cd ..; pwd -P )

old_tag=$(git describe --tags)

export $(grep -E -v '^#' "$project_path/tools/.version" | xargs)

# Big chain of commands we only want to run if the previous one was successful
echo -ne "Stopping all running containers" && \
    "$project_path"/bin/tdown &> /dev/null && \
    echo -e "...done\n\nPulling the latest code" && \
    git pull origin master --rebase && \
    source $project_path/tools/post_update.sh && \
    return &> /dev/null || exit

# Something failed...
echo -e "\n\x1B[31mThere was an error while updating.\x1B[0m"
echo "The update can be attempted again by running the $script_path/$(basename $0) script."
