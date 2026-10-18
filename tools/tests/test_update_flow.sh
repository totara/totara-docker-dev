#!/bin/bash

# Runs check_for_update.sh and update.sh end to end against clones in different states, answering the update prompt.
# Needs python3, which runs each command in a pseudo-terminal so the prompt can be answered.
# Usage: tools/tests/test_update_flow.sh

source "$(dirname "$0")/helpers.sh"

if ! command -v python3 &> /dev/null; then
    echo "python3 is required to run these tests"
    exit 1
fi

setup_test_env
build_upstream

# An unrelated repo on master to run commands from, to catch git calls that ignore the project path
other="$work/other"
git init -q "$other"
git -C "$other" commit -q --allow-empty -m other

# run_command <clone> <answer>: runs the clone's tcmd in a terminal from the unrelated repo and answers the update prompt
run_command() {
    (cd "$other" && run_in_terminal "$2" "$1/bin/tcmd" 2>&1 | tr -d '\r')
}

# run_update <clone> <answer>: runs the clone's update.sh directly in a terminal and answers any prompt
run_update() {
    (cd "$other" && run_in_terminal "$2" "$1/tools/update.sh" 2>&1 | tr -d '\r')
}

echo "Fresh clone of the master tip, accept"
dir=$(make_clone tip_accept)
out=$(run_command "$dir" y)
check "prompts about unreleased changes" '[[ "$out" == *"unreleased changes"* ]]'
check "moves to the latest release" '[[ $(head_of "$dir") == "$release" ]]'
check "stays on master" '[[ $(git -C "$dir" rev-parse --abbrev-ref HEAD) == master ]]'
check "runs post_update.sh" '[[ "$out" == *"Successfully updated to v1.10.0"* ]]'
check "doesn't run the original command" '[[ "$out" != *"COMMAND RAN"* ]]'

echo "Fresh clone of the master tip, decline"
dir=$(make_clone tip_decline)
out=$(run_command "$dir" n)
check "leaves the checkout alone" '[[ $(head_of "$dir") == "$tip" ]]'
check "runs the original command" '[[ "$out" == *"COMMAND RAN"* ]]'
out=$(run_command "$dir" y)
check "doesn't ask again within 7 days" '[[ "$out" != *"update?"* && $(head_of "$dir") == "$tip" ]]'

echo "Fresh clone of the master tip, just press Enter"
dir=$(make_clone tip_enter)
out=$(run_command "$dir" "")
check "shows no as the default" '[[ "$out" == *"[y/N]"* ]]'
check "leaves the checkout alone and runs the command" '[[ $(head_of "$dir") == "$tip" && "$out" == *"COMMAND RAN"* ]]'

echo "On an older release, accept"
dir=$(make_clone behind --branch v1.9.0)
out=$(run_command "$dir" y)
check "prompts that a release is available" '[[ "$out" == *"v1.10.0 is available"* ]]'
check "fast-forwards to the latest release" '[[ $(head_of "$dir") == "$release" ]]'

echo "On the latest release"
dir=$(make_clone current --branch v1.10.0)
out=$(run_command "$dir" y)
check "doesn't prompt" '[[ "$out" != *"update?"* && "$out" == *"COMMAND RAN"* ]]'
check "leaves the checkout alone" '[[ $(head_of "$dir") == "$release" ]]'

echo "Local commit on the latest release"
dir=$(make_clone current_local --branch v1.10.0)
add_local_commit "$dir"
before=$(head_of "$dir")
out=$(run_command "$dir" y)
check "doesn't prompt" '[[ "$out" != *"update?"* && $(head_of "$dir") == "$before" ]]'

echo "Local commit on an older release, accept"
dir=$(make_clone behind_local --branch v1.9.0)
add_local_commit "$dir"
out=$(run_command "$dir" y)
check "rebases onto the latest release" '[[ $(git -C "$dir" rev-parse HEAD^) == "$release" ]]'
check "keeps the local commit" '[[ $(git -C "$dir" log -1 --format=%s) == local ]]'

echo "Local commit on the master tip"
dir=$(make_clone tip_local)
add_local_commit "$dir"
before=$(head_of "$dir")
out=$(run_command "$dir" y)
check "shows a notice without prompting" '[[ "$out" == *"local commits on top of unreleased"* && "$out" != *"update?"* ]]'
check "leaves the checkout alone and runs the command" '[[ $(head_of "$dir") == "$before" && "$out" == *"COMMAND RAN"* ]]'

echo "Master tip with an uncommitted change to a file that differs from the release, accept"
dir=$(make_clone dirty)
echo mine > "$dir/file.txt"
out=$(run_command "$dir" y)
check "reports the failed update" '[[ "$out" == *"error while updating"* ]]'
check "keeps HEAD and the change" '[[ $(head_of "$dir") == "$tip" && $(cat "$dir/file.txt") == mine ]]'

echo "AUTO_UPDATE_TARGET=master on an older release, accept"
dir=$(make_clone master_target --branch v1.9.0)
echo AUTO_UPDATE_TARGET=master >> "$dir/.env"
out=$(run_command "$dir" y)
check "prompts about master" '[[ "$out" == *"available on master"* ]]'
check "moves to the upstream tip" '[[ $(head_of "$dir") == "$tip" ]]'

echo "AUTO_UPDATE_TARGET=master on the master tip"
dir=$(make_clone master_current)
echo AUTO_UPDATE_TARGET=master >> "$dir/.env"
out=$(run_command "$dir" y)
check "doesn't prompt" '[[ "$out" != *"update?"* && $(head_of "$dir") == "$tip" ]]'

echo "On a feature branch"
dir=$(make_clone feature_branch)
git -C "$dir" switch -q -c feature
out=$(run_command "$dir" y)
check "skips the check" '[[ "$out" != *"update?"* && "$out" == *"COMMAND RAN"* ]]'

echo "AUTO_UPDATE=0"
dir=$(make_clone disabled)
printf 'AUTO_UPDATE=0\nLOCAL_SRC=/nowhere\n' > "$dir/.env"
out=$(run_command "$dir" y)
check "skips the check" '[[ "$out" != *"update?"* && $(head_of "$dir") == "$tip" ]]'

echo "Upstream unreachable"
dir=$(make_clone offline)
out=$(DOCKER_DEV_REPO_URL="$work/missing.git" run_command "$dir" y)
check "doesn't prompt and runs the command" '[[ "$out" != *"update?"* && "$out" == *"COMMAND RAN"* ]]'

echo "Piped input with no terminal"
dir=$(make_clone piped)
out=$(cd "$other" && printf 'y\nsecond line\n' | "$dir/bin/tcmd" 2>&1)
check "skips the check and leaves the checkout alone" '[[ "$out" != *"update?"* && $(head_of "$dir") == "$tip" ]]'
check "passes all of the input to the command" '[[ "$out" == *"STDIN: y second line"* ]]'
check "doesn't record a check, so the next terminal run checks" '[[ ! -f "$dir/tools/.update" ]]'

echo "update.sh run directly on the master tip, accept"
dir=$(make_clone direct_accept)
out=$(run_update "$dir" y)
check "asks before moving back" '[[ "$out" == *"Move it back to the latest release (v1.10.0)?"* ]]'
check "moves to the latest release" '[[ $(head_of "$dir") == "$release" ]]'

echo "update.sh run directly on the master tip, decline"
dir=$(make_clone direct_decline)
out=$(run_update "$dir" n)
check "says nothing was changed" '[[ "$out" == *"Nothing was changed"* ]]'
check "leaves the checkout alone without stopping containers" '[[ $(head_of "$dir") == "$tip" && "$out" != *"Stopping"* ]]'

echo "update.sh run directly with LOCAL_SRC exported and AUTO_UPDATE_TARGET=master"
dir=$(make_clone exported_local_src)
echo AUTO_UPDATE_TARGET=master >> "$dir/.env"
out=$(export LOCAL_SRC=/somewhere/else; run_update "$dir" y)
check "reads .env and stays on the master tip" '[[ $(head_of "$dir") == "$tip" && "$out" != *"Move it back"* ]]'

echo "README install steps"
dir="$work/readme"
git clone -q --branch v1.10.0 "$upstream" "$dir"
git -C "$dir" switch -q -C master
check "ends up on master at the release" '[[ $(git -C "$dir" rev-parse --abbrev-ref HEAD) == master && $(head_of "$dir") == "$release" ]]'

check "never touches the repo it was run from" '[[ $(git -C "$other" rev-list --count HEAD) -eq 1 ]]'

finish
