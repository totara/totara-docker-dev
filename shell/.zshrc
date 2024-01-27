export TERM=xterm-256color
export ZSH="/root/.oh-my-zsh"

SAVEHIST=10000
HISTFILE=/root/.zsh_history/.hist

ZSH_THEME=powerlevel10k/powerlevel10k
plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

POWERLEVEL9K_MODE='nerdfont-complete'

# Shows logo and php version of the container
zsh_php_container_name(){
    local phpicon='\ue608'
    echo -n "${phpicon} ${CONTAINERNAME}"
}
POWERLEVEL9K_CUSTOM_CONTAINER="zsh_php_container_name"
POWERLEVEL9K_CUSTOM_CONTAINER_BACKGROUND="103"
POWERLEVEL9K_CUSTOM_CONTAINER_FOREGROUND="black"

# Shows the DB host if there is a config.php in the directory.
zsh_db_host(){
    is_site_root || exit
    local dbhost=$(config_var dbhost)
    if [[ "$dbhost" =~ "error" || "$dbhost" =~ "Warning" || "$dbhost" =~ "Notice" ]]; then
        print_error 'Incompatible PHP version or invalid config.php!'
        exit
    fi
    local dbicon='\uf1c0'
    echo -n "${dbicon} ${dbhost}"
}
POWERLEVEL9K_CUSTOM_DB="zsh_db_host"
POWERLEVEL9K_CUSTOM_DB_BACKGROUND="043"
POWERLEVEL9K_CUSTOM_DB_FOREGROUND="black"

# Shows the totara site version if there is a config.php/version.php in the directory.
zsh_totara_version(){
    is_site_root || exit
    local totaraicon='\uf829'
    echo -n "${totaraicon} $(totara_version)"
}
POWERLEVEL9K_CUSTOM_TOTARA="zsh_totara_version"
POWERLEVEL9K_CUSTOM_TOTARA_BACKGROUND="106"
POWERLEVEL9K_CUSTOM_TOTARA_FOREGROUND="black"

# Shows the current working directory. If you are within your project it is shortened, but shows full path if outside of it.
zsh_dir_name(){
    local diricon='\uf07c'
    local dirfull=$(pwd)
    local dir="${dirfull/\/var\/www\/totara\//"$"}"
    if [[ -z "$dir" ]]; then
        dir="$dirfull";
    fi
    echo -n "${diricon} ${dir}"
}
POWERLEVEL9K_CUSTOM_DIR="zsh_dir_name"
POWERLEVEL9K_CUSTOM_DIR_BACKGROUND="031"
POWERLEVEL9K_CUSTOM_DIR_FOREGROUND="black"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_container custom_db custom_totara custom_dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time)
POWERLEVEL9K_STATUS_CROSS=true
