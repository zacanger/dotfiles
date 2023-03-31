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

_sourceif "$HOME/.bash/config.sh"
_sourceif "$HOME/.bash/history.sh"
_sourceif "$HOME/.bash/path.sh"
_sourceif "$HOME/.bash/vars.sh"

if [ -d "$HOME/.bash/completion" ]; then
    for file in "$HOME"/.bash/completion/*; do
        _sourceif "$file"
    done
fi

if [ -d "$HOME/.bash/aliases" ]; then
    for file in "$HOME"/.bash/aliases/*; do
        _sourceif "$file"
    done
fi

_sourceif "$HOME/.bash/prompt.sh"

# all the functions
if [ -d "$HOME/.bash/functions" ]; then
    for file in "$HOME"/.bash/functions/*; do
        _sourceif "$file"
    done
fi

if [[ $(uname) == 'Darwin' ]] || [[ $(uname -a) == *'microsoft'* ]]; then
    # Macs yell at you if you use Bash
    export BASH_SILENCE_DEPRECATION_WARNING=1
    # On Mac, I only use one terminal,
    # so I just always attach to the same session
    [ -z "$TMUX" ] && { tmux attach || exec tmux new-session; }
else
    # On Linux, I use a tiling window manager, so I'll
    # usually want a separate session for each new terminal window.
    if [[ ! "$TERM" =~ screen ]] && \
        [[ ! "$TERM" =~ tmux ]] && \
        [[ ! "$TERM" =~ linux ]] && \
        [ -z "$TMUX" ]; then
        exec tmux
    fi
    :
fi
