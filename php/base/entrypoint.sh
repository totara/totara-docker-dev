#!/bin/bash

# Source each .sh file found in the /shell/ folder
echo 'for f in ~/custom_shell/*.sh; do [[ -e "$f" ]] && source "$f"; done;' >> ~/.bashrc
echo 'setopt +o nomatch' > ~/.zshrc
echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc
cat ~/.bashrc >> ~/.zshrc

/bin/bash -c "/root/.phpbrew/php/php-$PHPVERSION/sbin/php-fpm"
