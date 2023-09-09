# shellcheck shell=bash

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# little helper
_sourceif() {
    [ -f "$1" ] && . "$1"
}

if [[ -n "$_Z_DOT_LOADED" ]]; then
    return
fi

_sourceif "$HOME/.bash/bashrc.sh"
