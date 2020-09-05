# shellcheck shell=bash

# don't kill bg jobs on exit
shopt -u huponexit
# put multi-line commands into one history entry
shopt -s cmdhist
# update lines and cols after each command if needed
shopt -s checkwinsize
# autocorrect spelling on some things
shopt -s cdspell

# "**" in pathname matches all files & 0 or more dirs/subdirs; also, ".foo"
if [[ $(uname) == 'Linux' ]]; then
  shopt -s globstar
  shopt -s dotglob
  shopt -s dirspell
  shopt -s direxpand
  shopt -s checkjobs
fi

# check that hashed commands still exist before running them
shopt -s checkhash
# enable extended globbing: !(foo), ?(bar|baz)...
shopt -s extglob
# append history to $HISTFILE rather than overwriting it
shopt -s histappend
# if history expansion fails, reload the command to try again
shopt -s histreedit
# load history expansion result as the next command, don't run them directly
shopt -s histverify
# don't assume a word with a @ in it is a hostname
shopt -u hostcomplete
# use programmable completion, if available
shopt -s progcomp
# warn me if I try to shift nonexistent values off an array
shopt -s shift_verbose
# don't search $PATH to find files for the source builtin
shopt -u sourcepath

# see lesspipe(1)
if [ -x /usr/bin/lesspipe.sh ]; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
elif hash lesspipe 2>/dev/null; then
  eval "$(lesspipe)"
fi

# forward history search with ctrl-s
stty stop ""

# get core dumps
ulimit -c unlimited

# set tab width in terminal output
tabs -2

# color ls
if hash dircolors 2>/dev/null; then
  test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
fi

# dynamic title
case $TERM in
  xterm*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
  *)
    ;;
esac
