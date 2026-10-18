#!/bin/bash

# Helpers for finding the latest docker-dev release and working out where the checkout sits relative to it.
# Sourced by check_for_update.sh and update.sh, which must set $project_path first.

repo_url="${DOCKER_DEV_REPO_URL:-https://github.com/totara/totara-docker-dev.git}"

# Prints the highest vX.Y.Z tag on the upstream repo, or nothing if it can't be reached.
latest_release_tag() {
    git -C "$project_path" ls-remote --tags --refs "$repo_url" 'refs/tags/v*' 2>/dev/null \
        | awk '{print $2}' \
        | sed 's#^refs/tags/##' \
        | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
        | sed 's/^v//' \
        | sort -t. -k1,1n -k2,2n -k3,3n \
        | tail -n 1 \
        | sed 's/^/v/'
}

# Sets $release_state for $latest_tag to one of:
# * current - on the latest release, possibly with local commits on top
# * behind - a newer release is available
# * unreleased - on upstream master commits that haven't been released yet
# * unreleased-local - as above, with local commits on top
detect_release_state() {
    git -C "$project_path" fetch --quiet --no-tags "$repo_url" "+refs/tags/$latest_tag:refs/tags/$latest_tag" 2>/dev/null || return 1
    # Fetched last so FETCH_HEAD points at upstream master
    git -C "$project_path" fetch --quiet --no-tags "$repo_url" master 2>/dev/null || return 1

    local upstream base head
    upstream=$(git -C "$project_path" rev-parse FETCH_HEAD) || return 1
    head=$(git -C "$project_path" rev-parse HEAD) || return 1

    if ! git -C "$project_path" merge-base --is-ancestor "$latest_tag" "$head"; then
        release_state=behind
        return 0
    fi

    base=$(git -C "$project_path" merge-base "$head" "$upstream") || return 1
    if [[ $(git -C "$project_path" rev-list --count "$latest_tag..$base") -eq 0 ]]; then
        release_state=current
    elif [[ "$base" == "$head" ]]; then
        release_state=unreleased
    else
        release_state=unreleased-local
    fi
}
