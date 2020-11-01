# shellcheck shell=bash

peek() {
  tmux split-window -p 50 "$EDITOR" "$@"
}
