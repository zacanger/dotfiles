# vim: ft=sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't kill bg jobs on exit
shopt -u huponexit

# check size, one line, etc
shopt -s cmdhist
shopt -s checkwinsize

# "**" in pathname matches all files & 0 or more dirs/subdirs; also, ".foo"
shopt -s globstar
shopt -s dotglob

# see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export LESSOPEN="| $(which highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
export LESS=" -R"

# forward history search with ctrl-s
stty stop ""

# color ls
if [ -x /usr/bin/dircolors ]; then
  test -r $HOME/.dircolours && eval "$(dircolors -b $HOME/.dircolours)" || eval "$(dircolors -b)"
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# history stuff
shopt -s histappend # append
HISTCONTROL='erasedups:ignoreboth' # ignore lines with spaces & dups
HISTIGNORE="ls:l:la:lo:lS:lv:lT:ll:a:k:ld:lr:cd:lc:h:history:ranger:mocp:mu:q:exit:c:ds:ds.:clear:erm:w:gg:ZZ:q!:\:wq:\:Wq:..:.:cs:dt:co:ni:ns:vi:reload:gst:edrc:edal:fs:xtrlock:dbst:dbup:dbdn:\:q:ls*;k *;a *;* --help;* -h:nss:ncu:fetch:gf:pull:gd:g:v:nu:cerm:clearclip"
HISTSIZE= # length
HISTFILESIZE= # size
HISTTIMEFORMAT='%F %T  ' # timestamp
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"

# completions
bind 'set completion-query-items 100'                       # ask if over N possible completions
complete -d cd rmdir                                        # on cd, just show dirs
complete -A builtin builtin                                 # bash builtins
complete -A setopt set                                      # bash options
complete -A command command complete coproc exec hash type  # commands
complete -A directory cd pushd mkdir rmdir                  # dirs
complete -A function function                               # bash functions
complete -A helptopic help                                  # halp
complete -A job disown fg jobs                              # jobspecs
complete -A stopped bg                                      # maor jobs
complete -A binding bind                                    # readline
complete -A shopt shopt                                     # sh... opt...
complete -A signal trap                                     # signals
complete -A variable declare export readonly typeset        # variables
complete -A function -A variable unset                      # more vars

# autocorrect spelling on some things
shopt -s cdspell
shopt -s dirspell

# dynamic title
case $TERM in
  xterm*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
  *)
    ;;
esac

# include
export CDPATH=.:$HOME/Dropbox:$HOME/Dropbox/work:$HOME/Dropbox/work/repos:$HOME/Dropbox/z/bin:$HOME/Dropbox/z:/usr/local/lib:/usr/local/lib/node_modules
export PATH=$(npm bin):$HOME/.gem/global/bin:$HOME/.cabal/bin:$HOME/.local/bin:$HOME/.psvm/bin:$HOME/bin:$HOME/bin/x:$PATH
export VISUAL='nvim'
export EDITOR='nvim'
export MANPATH=$HOME/doc:$MANPATH
export NODE_ENV=development
export GITHUB_USER='zacanger'

export JOBS=max
ulimit -n 10240

XDG_CONFIG_HOME=$HOME/.config
if hash setxkbmap 2>/dev/null ; then
  /usr/bin/setxkbmap -option "caps:swapescape"
fi

# escape codes
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

# 0;30 Black
# 0;33 Brown
# 0;35 Purple
# 0;37 Light Gray
# 1;30 Dark Gray
# 1;31 Light Red
# 1;32 Light Green
# 1;34 Light Blue
# 1;35 Pink
# 1;36 Light Cyan
red='\033[1;31m'    # bold red
green='\033[1;32m'  # bold green
yell='\033[1;33m'   # bold yellow
blue='\033[1;34m'   # bold blue
purp='\033[1;35m'   # bold purple
cyan='\033[1;36m'   # bold light blue
white='\033[1;37m'  # bold white
reset='\033[0m'     # return the prompt to orig

tabs -2

eval $(opam config env)

# eval "$(rbenv init -)"
[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash

# keep aliases and functions on their own
if [ -f $HOME/.bash_aliases ]; then
  . $HOME/.bash_aliases
fi

if [ -d $HOME/.bash_functions ]; then
  for file in $HOME/.bash_functions/*; do
    . "$file"
  done
fi

if [ -d $HOME/.bash_completions ]; then
  for file in $HOME/.bash_completions/*; do
    . "$file"
  done
fi

# brew's bash completion
if [[ `uname` == 'Darwin' ]] ; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# aws completion
if hash aws_completer 2>/dev/null ; then
  complete -C aws_completer aws
fi

# and, finally... liquidprompt; load from interactive shell, don't from scripts/scp
echo $- | grep -q i 2>/dev/null && source /usr/share/liquidprompt/liquidprompt
