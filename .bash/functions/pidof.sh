# shellcheck shell=bash

# because macs don't have pidof

# save out because I alias grep to ag
_grep=$(which grep)
pidof() {
    if [[ $(uname) == 'Darwin' ]]; then
        ps -ef | $_grep -i "$1" | $_grep -v grep | awk '{print $2}'
    else
        $(which pidof) "$1"
    fi
}
