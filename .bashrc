# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# lines w space & dups, ignores: bash(1) for more
HISTCONTROL=ignoreboth
HISTIGNORE='ls:history:la:ranger:mocp'

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

# see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt
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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

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


# autocorrect cd
shopt -s cdspell

. /usr/share/autojump/autojump.sh

# Only load Liquid Prompt in interactive shells, not from a script or from scp
echo $- | grep -q i 2>/dev/null && source /usr/share/liquidprompt/liquidprompt

export PATH=$PATH:/usr/local/share/npm/bin:~/bin:/opt

### MOTD ###
      # Display MotD
      # if [[ -e $HOME/.motd ]]; then cat $HOME/.motd; fi

export PS1="[$(t | wc -l | sed -e's/ *//')] $PS1"
export EDITOR="nano"


if [ -d ~/.bash_functions ]; then
    for file in ~/.bash_functions/*; do
        . "$file"
    done
fi

if [ -e /home/zacanger/.nix-profile/etc/profile.d/nix.sh ]; then . /home/zacanger/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


## shline
#   function _update_ps1() {
#        local PREV_ERROR=$?
#        local JOBS=$(jobs -p | wc -l)
#        export PS1="$(python2.7 ~/.shline/shline.py --prev-error $PREV_ERROR --jobs $JOBS 2> /dev/null)"
#    }
#
#    export PROMPT_COMMAND="_update_ps1"
