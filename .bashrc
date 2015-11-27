# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# lines w space & dups, ignores: bash(1) for more
HISTCONTROL=ignoreboth
HISTIGNORE='ls:history:la:ranger:mocp:h:c:clear:'

# history append, length, timestamp
shopt -s histappend
HISTSIZE=$((1 << 12))
HISTFILESIZE=$((1 << 24))
HISTTIMEFORMAT='%F %T  '

# check size, one line, etc
shopt -s cmdhist
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# include .file in expansions
shopt -s dotglob

# see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# if [ -e /usr/share/terminfo/x/xterm-256color ] && [ "$COLORTERM" == "xfce4-terminal" ]; then
#     export TERM=xterm-256color
# fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

# record history immediately, rather than on exit
PROMPT_COMMAND='history -a'

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# if it's NOT ecma-48 (iso/iec-6429), which is very rare
	# we'd want to go with setf rather than setaf
	color_prompt=yes
    else
	color_prompt=
    fi
fi

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

# color ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolours && eval "$(dircolors -b ~/.dircolours)" || eval "$(dircolors -b)"
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# keep aliases in their own file, duh
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# programmable completion; enable if NOT enabled in /etc/bash.bashrc;
# /etc/profile needs to source that
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


#  XTERM_TITLE='\[\033]0;\h\007\]'
# [ "$IS_VIRTUAL_CONSOLE" ] && XTERM_TITLE=''
# PS1=$XTERM_TITLE'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# vi mode
# set -o vi
# bind -m vi-insert \\C-l:clear-screen        # make Ctrl-L work the same as it does in emacs mode


# autocorrect spelling on some things
shopt -s cdspell
shopt -s dirspell

#include

. /usr/share/autojump/autojump.sh
export CDPATH='.:/home/z/Dropbox/skool:/home/z/bin:/home/z/Dropbox/z:/usr/local/lib'
export PATH=$PATH:/usr/local/share/npm/bin:~/bin:/opt:$(find $HOME/bin/ -type d | paste -s -d:)
### MOTD ###
# Display MotD
# if [[ -e $HOME/.motd ]]; then cat $HOME/.motd; fi

# export PS1="[$(t | wc -l | sed -e's/ *//')] $PS1"
# export PS="\[\e[1;33m\]\w\[\e[;0;1m\] ($( dirsize -Hb )) \$\[\e[;0m\]" # add this bit on to keep dirsize in prompt (see ~/bin/dirsize)
export EDITOR="nvim"

if [ -d ~/.bash_functions ]; then
    for file in ~/.bash_functions/*; do
        . "$file"
    done
fi

# if [ -e /home/zacanger/.nix-profile/etc/profile.d/nix.sh ]; then . /home/zacanger/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


## shline
#   function _update_ps1() {
#        local PREV_ERROR=$?
#        local JOBS=$(jobs -p | wc -l)
#        export PS1="$(python2.7 ~/.shline/shline.py --prev-error $PREV_ERROR --jobs $JOBS 2> /dev/null)"
#    }
#
#    export PROMPT_COMMAND="_update_ps1"

# export PS1="$PS1\$(git-check)" # gh:oss6/git-check

# only show dirs on cd
complete -d cd rmdir
# bash builtins
complete -A builtin builtin
# bash options
complete -A setopt set
# commands
complete -A command command complete coproc exec hash type
# dirs
complete -A directory cd pushd mkdir rmdir
# funcs
complete -A function function
# halp
complete -A helptopic help
# jobspecs
complete -A job disown fg jobs
complete -A stopped bg
# readline
complete -A binding bind
# sh... opt....
complete -A shopt shopt
# signals
complete -A signal trap
# variables
complete -A variable declare export readonly typeset
complete -A function -A variable unset

# ask if more than x options
bind 'set completion-query-items 200'

# dynamic tytle
case $TERM in
xterm*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac

# Only load Liquid Prompt in interactive shells, not from a script or from scp
echo $- | grep -q i 2>/dev/null && source /usr/share/liquidprompt/liquidprompt

export SLACK_TOKEN='xoxp-3318091984-8228669395-14582732308-0f9a575714'
export SLACK_USERNAME='zacanger'

