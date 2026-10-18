#!/bin/bash

# Tests the functions in tools/release_helpers.sh directly.
# Usage: tools/tests/test_release_helpers.sh

source "$(dirname "$0")/helpers.sh"

setup_test_env
build_upstream
source "$project_root/tools/release_helpers.sh"

# state_of <clone>: prints the release state of a clone against v1.10.0
state_of() {
    project_path=$1
    latest_tag=v1.10.0
    release_state=
    detect_release_state && echo "$release_state"
}

echo "latest_release_tag"
project_path=$(make_clone tags)
tag=$(latest_release_tag)
check "picks the highest version, not the last in text order" '[[ "$tag" == v1.10.0 ]]'
git -C "$upstream" tag v1.10.1-rc1 "$tip"
git -C "$upstream" tag not-a-version "$tip"
tag=$(latest_release_tag)
check "ignores tags that aren't vX.Y.Z" '[[ "$tag" == v1.10.0 ]]'
git -C "$upstream" tag -d v1.10.1-rc1 not-a-version > /dev/null
tag=$(repo_url="$work/missing.git" latest_release_tag)
check "prints nothing when upstream can't be reached" '[[ -z "$tag" ]]'

echo "detect_release_state"
dir=$(make_clone current --branch v1.10.0)
check "on the latest release is current" '[[ $(state_of "$dir") == current ]]'

dir=$(make_clone current_local --branch v1.10.0)
add_local_commit "$dir"
check "local commits on the latest release is current" '[[ $(state_of "$dir") == current ]]'

dir=$(make_clone behind --branch v1.9.0)
check "on an older release is behind" '[[ $(state_of "$dir") == behind ]]'

dir=$(make_clone behind_local --branch v1.9.0)
add_local_commit "$dir"
check "local commits on an older release is behind" '[[ $(state_of "$dir") == behind ]]'

dir=$(make_clone unreleased)
check "master tip past the release is unreleased" '[[ $(state_of "$dir") == unreleased ]]'

dir=$(make_clone unreleased_local)
add_local_commit "$dir"
check "local commits on the master tip is unreleased-local" '[[ $(state_of "$dir") == unreleased-local ]]'

dir=$(make_clone unreachable)
check "fails when upstream can't be reached" '! (repo_url="$work/missing.git" state_of "$dir")'

finish
