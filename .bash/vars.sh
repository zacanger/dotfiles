# shellcheck shell=bash

export VISUAL=vim
export EDITOR=vim
export TERMINAL=xterm
export PYTHONSTARTUP=$HOME/.config/startup.py
export BROWSER=firefox
export XDG_CONFIG_HOME=$HOME/.config
export JOBS=max
export GPG_TTY=$(tty)
export LESSOPEN="| $(which highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
export LESS=" -R"
# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export GIT_EDITOR=vim
export GITHUB_USERNAME=zacanger

if [[ $(uname) == 'Darwin' ]]; then
    export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
    export MANPATH=/opt/homebrew/share/man:$MANPATH
    export MANPATH=/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH
    ulimit -n 10240
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS='--require-sha'
fi
