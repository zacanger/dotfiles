# shellcheck shell=bash

cdgr() {
  git rev-parse || return 1
  cd -- "$(git rev-parse --show-cdup)" || return 1
}
