# shellcheck shell=bash

scratch() {
  scratch_dir="$HOME/.tmp/$(date +%s)"
  mkdir -p "$scratch_dir"
  cd "$scratch_dir" || return
}
