#!/bin/bash

if [[ -z $release_date ]]; then
    echo "post_update.sh can't be run directly - please run tupdate instead"
    exit 1
fi

new_tag=$(git describe --tags)

if [[ "$release_date" -lt "20211112" ]]; then
    # Don't do anything for now.
    # In the future, we can use steps like this to fix things automatically where necessary.
    echo "" >> /dev/null
fi

echo -ne "\n\033[1;35mPulling the latest container images - this could take a few minutes...\033[0m\n\n"
$project_path/bin/tpull

if [[ -f "$project_path/tools/.stopped_services" ]]; then
    echo -ne "\n\033[1;35mStarting your containers again...\033[0m\n\n"
    xargs $project_path/bin/tup < "$project_path/tools/.stopped_services"
fi

echo -e "\n\033[1;35mSuccessfully updated to $new_tag!\x1B[0m"
echo -e "\033[1;35mView the release notes here: https://github.com/totara/totara-docker-dev/releases\x1B[0m"

if [[ -f "$project_path/tools/.stopped_services" ]]; then
    rm -f "$project_path/tools/.stopped_services"
else
    echo "Note: You will need to start your containers again with the tup command"
fi

