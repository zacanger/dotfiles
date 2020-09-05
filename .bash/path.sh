# shellcheck shell=bash

export GOPATH=$HOME/.go

if [[ $(uname) == 'Darwin' ]]; then
  export PATH="$HOME/bin:$HOME/.gem/global/bin:$HOME/.cabal/bin:$HOME/Library/Haskell/bin:/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$GOPATH/bin:/usr/local/sbin:$HOME/.local/bin:/usr/local/opt/gettext/bin::$HOME/.cargo/bin:$PATH"
else
  export PATH="$HOME/.local/bin:$HOME/bin:$HOME/bin/x:$HOME/.cargo/bin:$GOPATH/bin:$PATH"
fi
