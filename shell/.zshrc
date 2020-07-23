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

get_server_dir() {
    if [[ -f "./server/config.php" ]]; then
        totara_dir='server/'
    else
        totara_dir=''
    fi
}

# Shows the DB host if there is a config.php in the directory.
zsh_db_host(){
    get_server_dir
    [[ -f "config.php" ]] || exit
    local get_db_code="
        define(\"CLI_SCRIPT\", true);
        define(\"ABORT_AFTER_CONFIG\", true);
        require_once(\"${totara_dir}config.php\");
        if (isset(\$CFG->dbhost)) {
            echo(\$CFG->dbhost);
        } else {
            echo(0);
        }
    "
    local dbhost=`php -r "$get_db_code"`
    if [[ "$dbhost" =~ "error" || "$dbhost" =~ "Warning" || "$dbhost" =~ "Notice" ]]; then
        echo -n '\uf071 Incompatible PHP version or invalid config.php!'
        exit
    fi
    [[ "$dbhost" == '0' ]] && exit
    local dbicon='\uf1c0'
    echo -n "${dbicon} ${dbhost}"
}
POWERLEVEL9K_CUSTOM_DB="zsh_db_host"
POWERLEVEL9K_CUSTOM_DB_BACKGROUND="006"
POWERLEVEL9K_CUSTOM_DB_FOREGROUND="black"

# Shows the totara site version if there is a config.php/version.php in the directory.
zsh_totara_version(){
    get_server_dir
    [[ -f "${totara_dir}config.php" && -f "${totara_dir}version.php" ]] || exit
    local get_version_code="
        \$matches=array();
        \$totara_regex=\"/version[\s]*=[\s]*\'([^\']+)\'/\";
        preg_match_all(\$totara_regex, file_get_contents('${totara_dir}version.php'), \$matches);
        if (!empty(\$matches) && isset(\$matches[1][0])) {
            echo('t' . \$matches[1][0]);
            return;
        }
        \$moodle_regex=\"/release[\s]*=[\s]*\'([^\s]+)[^\']+\'/\";
        preg_match_all(\$moodle_regex, file_get_contents('${totara_dir}version.php'), \$matches);
        if (!empty(\$matches) && isset(\$matches[1][0])) {
            echo('moodle ' . \$matches[1][0]);
        }
    "
    local version=$(php -r "$get_version_code")
    [[ -z "$version" ]] && exit
    local totaraicon='\uf829'
    echo -n "${totaraicon} ${version}"
}
POWERLEVEL9K_CUSTOM_TOTARA="zsh_totara_version"
POWERLEVEL9K_CUSTOM_TOTARA_BACKGROUND="106"
POWERLEVEL9K_CUSTOM_TOTARA_FOREGROUND="black"

# Shows the current working directory. If you are within your project it is shortened, but shows full path if outside of it.
zsh_dir_name(){
    local diricon='\uf07c'
    local dirfull=$(pwd)
    local dir=$(echo "$dirfull" | grep -oP "^/var/www/totara/\K.*")
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
