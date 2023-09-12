#!/bin/bash

# Source each .sh file found in the /shell/ folder, always source the default_aliases.sh file first
echo 'if [[ -e "/root/custom_shell/default-aliases.sh" ]] then source "/root/custom_shell/default-aliases.sh"; fi' >> ~/.bashrc
echo 'for f in /root/custom_shell/*.sh; do [[ "$f" != "/root/custom_shell/default-aliases.sh" && -e "$f" ]] && source "$f"; done;' >> ~/.bashrc
echo 'setopt +o nomatch' > ~/.zshrc
echo 'source ~/custom_shell/.zshrc' >> ~/.zshrc
cat ~/.bashrc >> ~/.zshrc

/bin/bash -c "/root/.phpbrew/php/php-$PHPVERSION/sbin/php-fpm"
