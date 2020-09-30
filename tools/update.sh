#!/bin/bash

if [[ -z "$LOCAL_SRC" ]]; then
    SCRIPTPATH=$( cd "$(dirname $0)" || exit; pwd -P )
    PROJECTPATH=$( cd "$SCRIPTPATH" && cd ..; pwd -P )
    export $(grep -E -v '^#' "$PROJECTPATH/.env" | xargs)
fi

OLD_TAG=`git describe --tags`

git pull origin master

# Define additional update code after this line


# Define additional update code after this line

if [ $? -eq 0 ]; then
  CURRENT_TAG=`git describe --tags`
  echo -e "\x1B[2mSuccessfully updated to $CURRENT_TAG from $OLD_TAG\x1B[0m"
else
  echo -e "\x1B[31mThere was an error while updating\x1B[0m"
fi
