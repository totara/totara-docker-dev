#!/bin/bash

if [[ -z $release_date ]]; then
    echo "post_update.sh can't be run directly - please run update.sh instead"
    exit 1
fi

new_tag=$(git describe --tags)

if [[ "$release_date" -lt "20211112" ]]; then
    # Don't do anything for now.
    # In the future, we can use steps like this to fix things automatically where necessary.
    echo "" >> /dev/null
fi

if [[ ! $? -eq 0 ]]; then
    # Something went wrong in the custom upgrade steps...
    echo "An error occurred in the docker-dev specific upgrade steps!"
    return &> /dev/null || exit
fi

echo -ne "\nPulling the latest container images - this could take a few minutes" && \
$project_path/bin/tpull &> /dev/null && \
echo -e "...done\n\n\x1B[2mSuccessfully updated to $new_tag from $old_tag\x1B[0m" && \
echo "View the latest changes here: https://github.com/totara/totara-docker-dev/releases/latest" && \
echo "Note: You will need to start your containers again with the tup command"
