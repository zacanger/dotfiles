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
[ -x /usr/bin/lesspipe.sh ] && eval "$(SHELL=/bin/sh lesspipe.sh)"

export LESSOPEN="| $(which highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
export LESS=" -R"

# forward history search with ctrl-s
stty stop ""

# color ls
if [ -x /usr/bin/dircolors ] ; then
  test -r $HOME/.dircolors && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# history stuff
shopt -s histappend # append
HISTCONTROL='erasedups:ignoreboth' # ignore lines with spaces & dups
HISTIGNORE="ls:l:la:lo:lS:lv:lT:ll:a:k:ld:lr:cd:lc:h:history:ranger:mocp:mu:q:exit:c:ds:ds.:clear:erm:w:gg:ZZ:q!:\:wq:\:Wq:..:.:cs:dt:co:ni:ns:vi:reload:gst:edrc:edal:fs:xtrlock:dbst:dbup:dbdn:\:q:ls*;k *;a *;* --help;* -h:nss:ncu:fetch:gf:pull:gd:g:v:nu:cerm:clc"
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

export CDPATH=.:$HOME/Dropbox:$HOME/Dropbox/work:$HOME/Dropbox/work/repos:$HOME/Dropbox/z:/usr/local/lib
export PATH=$(npm bin):$HOME/.local/bin:$HOME/bin:$HOME/bin/x:$HOME/.gem/ruby/2.5.0/bin/:$PATH
export VISUAL='nvim'
export EDITOR='nvim'
export NODE_ENV=development
export GITHUB_USER='zacanger'

export JOBS=max
# ulimit -n 10240

XDG_CONFIG_HOME=$HOME/.config
if hash setxkbmap 2>/dev/null ; then
  /usr/bin/setxkbmap -option "caps:swapescape"
fi

tabs -2

# better yaourt colors
export YAOURT_COLORS="nb=1:pkg=1:ver=1;32:lver=1;45:installed=1;42:grp=1;34:od=1;41;5:votes=1;44:dsc=0:other=1;35"

# aliases, functions, and completions in their own files
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

# load from interactive shell, don't from scripts/scp
echo $- | grep -q i 2>/dev/null && source /usr/bin/liquidprompt
