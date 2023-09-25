# shellcheck shell=bash

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# TODO: I don't remember why I added this,
# but it's not working in some environments.
# if [[ -n "$_Z_DOT_LOADED" ]]; then return; fi

# little helper
_sourceif() {
    [ -f "$1" ] && . "$1"
}

current_rc=${BASH_SOURCE[0]}
while [ -L "$current_rc" ]; do # resolve $current_rc until the file is no longer a symlink
  config_dir=$( cd -P "$( dirname "$current_rc" )" >/dev/null 2>&1 && pwd )
  current_rc=$(readlink "$current_rc")
  [[ $current_rc != /* ]] && current_rc=$config_dir/$current_rc # if $current_rc was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
config_dir=$( cd -P "$( dirname "$current_rc" )" >/dev/null 2>&1 && pwd )

_sourceif "$config_dir/config.sh"
_sourceif "$config_dir/history.sh"
_sourceif "$config_dir/path.sh"
_sourceif "$config_dir/vars.sh"

if [ -d "$config_dir/completion" ]; then
    for file in "$config_dir"/completion/*; do
        _sourceif "$file"
    done
fi

if [ -d "$config_dir/aliases" ]; then
    for file in "$config_dir"/aliases/*; do
        _sourceif "$file"
    done
fi

_sourceif "$config_dir/prompt.sh"

# all the functions
if [ -d "$config_dir/functions" ]; then
    for file in "$config_dir"/functions/*; do
        _sourceif "$file"
    done
fi

if hash tmux 2>/dev/null; then
    if [[ $(uname) == 'Darwin' ]] || [[ $(uname -a) == *'microsoft'* ]]; then
        # Macs yell at you if you use Bash
        export BASH_SILENCE_DEPRECATION_WARNING=1
        # On Mac, I only use one terminal,
        # so I just always attach to the same session
        [ -z "$TMUX" ] && { tmux attach || exec tmux new-session; }
#     else
#         # On Linux, I use a tiling window manager, so I'll
#         # usually want a separate session for each new terminal window.
#         if [[ ! "$TERM" =~ screen ]] && \
#             [[ ! "$TERM" =~ tmux ]] && \
#             [[ ! "$TERM" =~ linux ]] && \
#             [ -z "$TMUX" ]; then
#                     exec tmux
#         fi
#         :
    fi
fi

if [[ $(uname) == 'Linux' ]]; then
    # n-install: http://git.io/n-install-repo
    export N_PREFIX="$HOME/n"
    [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"
fi

# _Z_DOT_LOADED=1
