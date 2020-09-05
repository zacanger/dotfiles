# shellcheck shell=bash

export VISUAL=nvim
export EDITOR=nvim
export TERMINAL=st
export PYTHONSTARTUP=$HOME/.config/startup.py
export BROWSER=firefox
export XDG_CONFIG_HOME=$HOME/.config
export JOBS=max
export GPG_TTY=$(tty)
export LESSOPEN="| $(which highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
export LESS=" -R"
# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if [[ $(uname) == 'Darwin' ]]; then
  # i'm at work
  export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
  ulimit -n 10240
fi
