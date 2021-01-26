# shellcheck shell=bash

export GOPATH=$HOME/.go

if [[ $(uname) == 'Darwin' ]]; then
    export PATH="$HOME/bin:$PATH"
    # intell brew stuff is at /usr/local, silicon is at /opt
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH"
    export PATH="/usr/local/sbin:$HOME/.local/bin:/usr/local/opt/gettext/bin:$PATH"
    export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/opt/curl/bin:$PATH" # brew link --force doesn't work for this
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="$GOPATH/bin:$PATH"
else
    export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$GOPATH/bin:$PATH"
fi
