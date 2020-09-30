#!/bin/bash

if [[ -z "$LOCAL_SRC" ]]; then
    SCRIPTPATH=$( cd "$(dirname $0)" || exit; pwd -P )
    PROJECTPATH=$( cd "$SCRIPTPATH" && cd ..; pwd -P )
    export $(grep -E -v '^#' "$PROJECTPATH/.env" | xargs)
fi

# We don't want to update it if:
# * Automatic updating is disabled in .env
# * The current user doesn't have write permissions nor owns the docker-dev directory
# * The current branch is not master
# * Git isn't available
if [[ "$AUTO_UPDATE" == "0" ]] \
   || [[ ! -w "$PROJECTPATH" || ! -O "$PROJECTPATH" ]] \
   || [[ `git rev-parse --abbrev-ref HEAD` != "master" ]] \
   || ! command -v git &>/dev/null; then
    return
fi

# Check when we last checked for updates
CURRENT_EPOCH=`date +%s`

UPDATE_EPOCH() {
    echo "LAST_EPOCH=$CURRENT_EPOCH" > "$PROJECTPATH/tools/.update"
}

if [[ ! -f "$PROJECTPATH/tools/.update" ]]; then
    # Haven't updated before, can skip for now.
    UPDATE_EPOCH
    return
fi

export $(grep -E -v '^#' "$PROJECTPATH/tools/.update" | xargs)
if [[ -z "$LAST_EPOCH" ]]; then
    # Haven't updated before, can skip for now.
    UPDATE_EPOCH
    return
fi

SEVEN_DAYS=604800
EPOCH_DIFF=`expr $CURRENT_EPOCH - $LAST_EPOCH` 
if [ "$EPOCH_DIFF" -lt "$SEVEN_DAYS" ]; then
    # Last updated less than 7 days ago, can skip for now.
    return
fi

# If the current head is the same as the latest remote master then we don't need to update
CURRENT_HASH=`git rev-parse HEAD`
LATEST_HASH=($( git ls-remote --heads https://github.com/totara/totara-docker-dev.git refs/heads/master))
LATEST_HASH=${LATEST_HASH[0]}
if [[ "$CURRENT_HASH" == "$LATEST_HASH" ]]; then
    # There aren't any updates. Check again in 2 days.
    UPDATE_EPOCH
    return
fi

read -p "There is a newer version of totara docker-dev available. Would you like to update? [Y/n]" CONFIRM
if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
    source ./update.sh
fi

UPDATE_EPOCH
