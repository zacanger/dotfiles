# shellcheck shell=bash

acp() {
  git add -A
  git commit -m "$1"
  git push
}
