# shellcheck shell=bash

# because macs don't have pidof

pidof() {
  if [[ $(uname) == 'Darwin' ]]; then
    ps -ef | grep -i "$1" | grep -v grep | awk '{print $2}'
  else
    $(which pidof) "$1"
  fi
}
