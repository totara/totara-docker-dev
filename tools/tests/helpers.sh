#!/bin/bash

# Shared setup for the update script tests. Builds a throwaway upstream repo with release tags, so nothing touches the
# real checkout, GitHub or the user's git config.

project_root=$( cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit; pwd -P )

passed=0
failed=0

check() {
    local name=$1 condition=$2
    if eval "$condition"; then
        echo "  PASS: $name"
        passed=$((passed + 1))
    else
        echo "  FAIL: $name"
        failed=$((failed + 1))
    fi
}

finish() {
    echo
    echo "$passed passed, $failed failed"
    [[ $failed -eq 0 ]]
}

setup_test_env() {
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT

    export GIT_CONFIG_NOSYSTEM=1
    export GIT_CONFIG_GLOBAL="$work/gitconfig"
    git config --global user.name test
    git config --global user.email test@example.com
    git config --global init.defaultBranch master
    git config --global advice.detachedHead false
    git config --global commit.gpgsign false
    git config --global tag.gpgsign false
}

# Creates $upstream with this history on master:
#   c1 (v1.9.0) - c2 (v0.0.0-test1) - c3 (v1.10.0) - c4 - c5
# and sets $tip, $release and $old_release to the matching commit hashes.
build_upstream() {
    local seed="$work/seed"
    mkdir -p "$seed/tools" "$seed/bin"
    cp "$project_root"/tools/{release_helpers,check_for_update,update,post_update}.sh "$project_root/tools/.version" "$seed/tools/"

    printf '#!/bin/bash\nexit 0\n' > "$seed/bin/tdown"
    cp "$seed/bin/tdown" "$seed/bin/tpull"
    # Stands in for tpull/tdb, which don't cd into the project before the update check
    cat > "$seed/bin/tcmd" <<'EOF'
#!/bin/bash
script_path="$( cd "$(dirname "$0")" ; pwd -P )"
project_path="$( cd $script_path && cd ..; pwd -P )"
set -a; source "$project_path/.env"; set +a
source "$project_path/tools/check_for_update.sh"
echo "COMMAND RAN"
# Shows whether the update check left the command's piped input alone
if [[ ! -t 0 ]]; then
    echo "STDIN: $(cat | tr '\n' ' ')"
fi
EOF
    chmod +x "$seed"/bin/*
    printf '.env\ntools/.update\n' > "$seed/.gitignore"

    echo "1.9.0" > "$seed/version.txt"
    echo a > "$seed/file.txt"
    git -C "$seed" init -q
    git -C "$seed" add -A
    git -C "$seed" commit -qm c1
    git -C "$seed" tag v1.9.0
    echo b > "$seed/file.txt"
    git -C "$seed" commit -qam c2
    git -C "$seed" tag v0.0.0-test1
    echo "1.10.0" > "$seed/version.txt"
    git -C "$seed" commit -qam c3
    git -C "$seed" tag v1.10.0
    echo d > "$seed/file.txt"
    git -C "$seed" commit -qam c4
    echo e > "$seed/other.txt"
    git -C "$seed" add -A
    git -C "$seed" commit -qm c5

    upstream="$work/upstream.git"
    git clone -q --bare "$seed" "$upstream"
    export DOCKER_DEV_REPO_URL="$upstream"

    tip=$(git -C "$upstream" rev-parse master)
    release=$(git -C "$upstream" rev-parse 'v1.10.0^{commit}')
    old_release=$(git -C "$upstream" rev-parse 'v1.9.0^{commit}')
}

# make_clone <name> [git clone args...]
# Clones upstream onto a local master branch with a minimal .env, and prints the clone's path.
make_clone() {
    local dir="$work/$1"
    shift
    git clone -q "$@" "$upstream" "$dir"
    git -C "$dir" switch -q -C master
    printf 'AUTO_UPDATE=1\nLOCAL_SRC=/nowhere\n' > "$dir/.env"
    echo "$dir"
}

# run_in_terminal <answer> <command>: runs the command in a pseudo-terminal and answers its update prompt, if it shows one
run_in_terminal() {
    python3 "$project_root/tools/tests/run_in_terminal.py" "$1" "$2"
}

add_local_commit() {
    echo local > "$1/local.txt"
    git -C "$1" add local.txt
    git -C "$1" commit -qm local
}

head_of() {
    git -C "$1" rev-parse HEAD
}
