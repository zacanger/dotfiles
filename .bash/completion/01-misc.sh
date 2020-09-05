# shellcheck shell=bash

# brew's bash completion
if [[ $(uname) == 'Darwin' ]]; then
  _sourceif "$(brew --prefix)/etc/bash_completion"
fi

# aws completion
if hash aws_completer 2>/dev/null ; then
  complete -C aws_completer aws
fi
