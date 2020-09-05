# shellcheck shell=bash

if hash git &>/dev/null; then
  diff() {
    git diff --no-index --color-words "$@"
  }
fi
