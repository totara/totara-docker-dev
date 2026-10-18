#!/bin/bash

if [[ -z "$project_path" ]]; then
    script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
    project_path=$( cd "$script_path" && cd ..; pwd -P )
fi

# Always read .env here, as the calling shell may already have some of its variables (like LOCAL_SRC) set.
if [[ -f "$project_path/.env" ]]; then
    set -a; source "$project_path/.env"; set +a
fi

old_tag=$(git -C "$project_path" describe --tags)

# shellcheck disable=SC2046 # word splitting is wanted, one export per line
export $(grep -E -v '^#' "$project_path/tools/.version" | xargs)

source "$project_path/tools/release_helpers.sh"

# Work out where we are if check_for_update.sh didn't already, e.g. when this script is run directly.
# This happens before anything is stopped, so a refusal leaves the containers running.
if [[ "$AUTO_UPDATE_TARGET" != "master" && ( -z "$latest_tag" || -z "$release_state" ) ]]; then
    latest_tag=$(latest_release_tag)
    if [[ -z "$latest_tag" ]] || ! detect_release_state; then
        echo "Couldn't check for the latest release at $repo_url"
        return 1 &> /dev/null || exit 1
    fi
fi

if [[ "$AUTO_UPDATE_TARGET" != "master" && "$release_state" == "unreleased-local" ]]; then
    echo "There are local commits on top of unreleased changes from master. Move them onto $latest_tag manually, or set AUTO_UPDATE_TARGET=master in .env."
    return 1 &> /dev/null || exit 1
fi

# Moving back from unreleased commits isn't an obvious update, so confirm it unless the user already has.
if [[ "$AUTO_UPDATE_TARGET" != "master" && "$release_state" == "unreleased" && "$update_confirmed" != "1" ]]; then
    printf 'totara-docker-dev is on unreleased changes from master. Move it back to the latest release (%s)? [y/N] ' "$latest_tag"
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Nothing was changed. To stay on master, set AUTO_UPDATE_TARGET=master in .env."
        return &> /dev/null || exit
    fi
fi

pull_latest() {
    if [[ "$AUTO_UPDATE_TARGET" == "master" ]]; then
        git -C "$project_path" fetch "$repo_url" master && \
            git -C "$project_path" rebase FETCH_HEAD
        return
    fi

    case "$release_state" in
        behind)
            if git -C "$project_path" merge-base --is-ancestor HEAD "$latest_tag"; then
                git -C "$project_path" merge --ff-only "$latest_tag"
            else
                # Keep any local commits on top of the new release
                git -C "$project_path" rebase "$latest_tag"
            fi
            ;;
        unreleased)
            # Move back from unreleased master commits to the release. Refuses to run if uncommitted changes would be lost.
            git -C "$project_path" reset --keep "$latest_tag"
            ;;
        *)
            echo "Already on the latest release ($latest_tag)"
            ;;
    esac
}

# Big chain of commands we only want to run if the previous one was successful
if echo -ne "Stopping all running containers" && \
    "$project_path"/bin/tdown &> /dev/null && \
    echo -e "...done\n\nPulling the latest code" && \
    pull_latest && \
    source $project_path/tools/post_update.sh; then
    return &> /dev/null || exit
fi

# Something failed...
echo -e "\n\x1B[31mThere was an error while updating.\x1B[0m"
echo "The update can be attempted again by running the $project_path/tools/update.sh script."
