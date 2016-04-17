#############################################################################
 ####  ~/.bashrc: run for non-login shells, sources most other configs  ####
 ####           check /usr/share/doc/bash & /etc for examples           ####
#############################################################################

## THESE THINGS ARE KINDA IMPORTANT AND STUFF I GUESS
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

# forward history search with ctrl-s
stty stop ""

# color ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolours && eval "$(dircolors -b ~/.dircolours)" || eval "$(dircolors -b)"
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# history stuff
HISTCONTROL='erasedups:ignoreboth' # ignore lines with spaces & dups
HISTIGNORE='ls:l:la:lo:lS:lT:ll:a:k:ld:lr:cd:lc:h:history:ranger:mocp:mu:q:exit:c:ds:ds.:clear:erm:gg:ZZ:q!:\:wq:\:Wq:..:.:cs:dt:co:ni:ns:vi'
shopt -s histappend # append
HISTSIZE= # length
HISTFILESIZE= # size
HISTTIMEFORMAT='%F %T  ' # timestamp
PROMPT_COMMAND='history -a' # record history NOW, not on exit

# completions
bind 'set completion-query-items 100' # ask if over N possible completions
complete -d cd rmdir # on cd, just show dirs
complete -A builtin builtin # bash builtins
complete -A setopt set # bash options
complete -A command command complete coproc exec hash type # commands
complete -A directory cd pushd mkdir rmdir #dirs
complete -A function function # bash functions
complete -A helptopic help # halp
complete -A job disown fg jobs # jobspecs
complete -A stopped bg # maor jobs
complete -A binding bind # readline
complete -A shopt shopt # sh... opt...
complete -A signal trap # signals
complete -A variable declare export readonly typeset #variables
complete -A function -A variable unset # more vars

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
export CDPATH='.:/home/z/Dropbox/skool:/home/z/Dropbox/z/bin:/home/z/Dropbox/z:/usr/local/lib:/usr/local/lib/node_modules'
export PATH=$PATH:/usr/local/share/npm/bin:/home/z/Dropbox/z/bin:/opt:~/.gem/global/bin:$(find $HOME/bin/ -type d | paste -s -d:)
export EDITOR='nvim'
export SLACK_USERNAME='zacanger'
export LOLCOMMITS_ANIMATE='2'
export MANPATH=$MANPATH:/home/z/doc
export NODE_ENV=development
export ATOM_DEV_RESOURCE_PATH='~/.atom/dev'

# j, rbenv, and fzf
. /usr/share/autojump/autojump.sh

# eval "$(rbenv init -)"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# keep aliases and functions on their own
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -d ~/.bash_functions ]; then
    for file in ~/.bash_functions/*; do
        . "$file"
    done
fi

# same for npm completion
if [ -f ~/.npm-completion ]; then
  . ~/.npm-completion
fi

# and git completion
if [ -f ~/.git-completion ]; then
  . ~/.git-completion
fi

# and hub completion
if [ -f ~/.hub-completion ]; then
  . ~/.hub-completion
fi

# and, finally... liquidprompt; load from interactive shell, don't from scripts/scp
echo $- | grep -q i 2>/dev/null && source /usr/share/liquidprompt/liquidprompt

############################################################
 ## FROM HERE DOWN, IT'S ALL JUST UNUSED BITS AND PIECES ##
 ##  alternate prompts, extras, other term titles, etc.  ##
############################################################
## the usual favourite prompt, when not using `liquidprompt`
## set variable identifying the chroot you work in (used in the prompt below)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi
## (this is the prompt i was talking about.) fancy prompt (in color)
# case "$TERM" in
#     xterm-color) color_prompt=yes;;
# esac
# force_color_prompt=yes
# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#   # if it's NOT ecma-48 (iso/iec-6429), which is very rare
#   # we'd want to go with setf rather than setaf
#   color_prompt=yes
#     else
#   color_prompt=
#     fi
# fi
## very nice thing for git, if not using liquidprompt
# export PS1="$PS1\$(git-check)" # gh:oss6/git-check

## shline
# function _update_ps1() {
#      local PREV_ERROR=$?
#      local JOBS=$(jobs -p | wc -l)
#      export PS1="$(python2.7 ~/.shline/shline.py --prev-error $PREV_ERROR --jobs $JOBS 2> /dev/null)"
#  }
#
#  export PROMPT_COMMAND="_update_ps1"

# if [ -e /usr/share/terminfo/x/xterm-256color ] && [ "$COLORTERM" == "xfce4-terminal" ]; then
#     export TERM=xterm-256color
# fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

#  XTERM_TITLE='\[\033]0;\h\007\]'
# [ "$IS_VIRTUAL_CONSOLE" ] && XTERM_TITLE=''
# PS1=$XTERM_TITLE'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# vi mode
# set -o vi
# bind -m vi-insert \\C-l:clear-screen  # make Ctrl-L work the same as it does in emacs mode

# programmable completion; enable if NOT enabled in /etc/bash.bashrc;
# /etc/profile needs to source that
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi

# export PS1="[$(t | wc -l | sed -e's/ *//')] $PS1"

# export PS="\[\e[1;33m\]\w\[\e[;0;1m\] ($( dirsize -Hb )) \$\[\e[;0m\]" # add this bit on to keep dirsize in prompt (see ~/bin/dirsize)

# maybe puts a clock in the prompt?
# PS1='\[\u@\h \T \w]\$'
# or this way?
# export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:[\t]:\w\$ "

# should give nice prompt with date and time
# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\$'
# else
#    # PS1='${debian_chroot:+($debian_chroot)}[*\u@Ubuntu*]:\w\$ '
#     PS1='${debian_chroot:+($debian_chroot)}[*\u@Ubuntu*]\t:\w\$ '
# fi

