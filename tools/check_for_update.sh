#!/bin/bash

if [[ -z "$project_path" ]]; then
    script_path=$( cd "$(dirname "$0")" || exit; pwd -P )
    project_path=$( cd "$script_path" && cd ..; pwd -P )
fi

# Always read .env here, as the calling shell may already have some of its variables (like LOCAL_SRC) set.
if [[ -f "$project_path/.env" ]]; then
    set -a; source "$project_path/.env"; set +a
fi

# We don't want to update it if:
# * Nobody is at a terminal to answer the prompt (piped input, cron, CI), so we don't swallow the command's input
# * Automatic updating is disabled in .env
# * The current user doesn't have write permissions nor owns the docker-dev directory
# * The current branch is not master
# * Git isn't available
if [[ ! -t 0 ]] \
   || [[ "$AUTO_UPDATE" == "0" ]] \
   || [[ ! -w "$project_path" || ! -O "$project_path" ]] \
   || ! command -v git &>/dev/null \
   || [[ $(git -C "$project_path" rev-parse --abbrev-ref HEAD) != "master" ]]; then
    return &> /dev/null || exit
fi

# Check when we last checked for updates.
current_time=$(date +%s)

update_time() {
    echo "last_update_time=$current_time" > "$project_path/tools/.update"
}

if [[ -f "$project_path/tools/.update" ]]; then
    # shellcheck disable=SC2046 # word splitting is wanted, one export per line
    export $(grep -E -v '^#' "$project_path/tools/.update" | xargs)
fi

# If we haven't checked before then check straight away, so a fresh clone can be moved onto the latest release.
if [[ -n "$last_update_time" ]]; then
    seven_days_in_seconds=604800
    update_time_difference=$(expr $current_time - $last_update_time)
    if [ "$update_time_difference" -lt "$seven_days_in_seconds" ]; then
        # Last updated less than 7 days ago, can skip for now.
        return &> /dev/null || exit
    fi
fi

# No matter what, something will be done now, so update the last updated timestamp.
update_time

source "$project_path/tools/release_helpers.sh"

if [[ "$AUTO_UPDATE_TARGET" == "master" ]]; then
    # If the current head is the same as the latest remote master then we don't need to update.
    current_version_hash=$(git -C "$project_path" rev-parse HEAD)
    latest_version_hash=$(git -C "$project_path" ls-remote --heads "$repo_url" refs/heads/master | awk '{print $1}')
    if [[ -z "$latest_version_hash" || "$current_version_hash" == "$latest_version_hash" ]]; then
        # There aren't any updates. Will check again in 7 days.
        return &> /dev/null || exit
    fi
    update_message="There is a newer version of totara-docker-dev available on master."
else
    latest_tag=$(latest_release_tag)
    if [[ -z "$latest_tag" ]] || ! detect_release_state; then
        # Couldn't reach the remote. Will check again in 7 days.
        return &> /dev/null || exit
    fi
    case "$release_state" in
        behind)
            update_message="totara-docker-dev $latest_tag is available."
            ;;
        unreleased)
            update_message="totara-docker-dev is on unreleased changes from master. Switching to the latest release ($latest_tag) is recommended. To stay on master, set AUTO_UPDATE_TARGET=master in .env."
            ;;
        unreleased-local)
            echo "totara-docker-dev has local commits on top of unreleased changes from master, so it can't be moved to the latest release ($latest_tag) automatically."
            return &> /dev/null || exit
            ;;
        *)
            # Already on the latest release. Will check again in 7 days.
            return &> /dev/null || exit
            ;;
    esac
fi

printf '%s Updating will stop all running containers. Would you like to update? [y/N] ' "$update_message"
read -r confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    update_confirmed=1
    source "$project_path/tools/update.sh"
    # Containers have been stopped, so should quit out and not continue running whatever the command was.
    exit
fi

# Now we continue on and run the command that they originally wanted to run.
