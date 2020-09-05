# shellcheck shell=bash

ac() {
  git add -A
  git commit -m "$1"
}
