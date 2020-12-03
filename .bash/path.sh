# shellcheck shell=bash

export GOPATH=$HOME/.go

if [[ $(uname) == 'Darwin' ]]; then
  export PATH="$HOME/bin:$HOME/.gem/global/bin:$HOME/.cabal/bin:$HOME/Library/Haskell/bin:$PATH"
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH"
  export PATH="$GOPATH/bin:/usr/local/sbin:$HOME/.local/bin:/usr/local/opt/gettext/bin:$PATH"
  export PATH="$HOME/.cargo/bin:$PATH"
else
  export PATH="$HOME/.local/bin:$HOME/bin:$HOME/bin/x:$HOME/.cargo/bin:$GOPATH/bin:$PATH"
fi
