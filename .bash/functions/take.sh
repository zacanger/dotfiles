# shellcheck shell=bash

take() {
  mkdir -p "$1"
  cd "$1" || return
}
