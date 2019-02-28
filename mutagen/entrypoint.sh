#!/bin/bash

cd /root/

echo "Starting mutagen daemon"

if [[ ! -d /syncit ]]
then
    mkdir /syncit
fi

./mutagen daemon start

./mutagen list | grep 'totara' &> /dev/null
if [ $? != 0 ]; then
   ./mutagen create \
    --default-directory-mode=0755 \
    --default-file-mode=0644 \
    --ignore-vcs \
    --ignore .idea \
    --ignore .DS_Store \
    /tmp /root/totara/test
fi

./mutagen monitor
