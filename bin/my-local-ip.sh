#!/usr/bin/env bash
set -eu

has() {
  command -v "$1" >/dev/null 2>&1
}

main() {
  if has "ifconfig"; then
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
    exit
  fi

  # OSTYPE is not set on debian chroot
  if [[ -n "$OSTYPE" && "$OSTYPE" == *'arwin'* ]]; then
    local ethernet
    ethernet=$(ipconfig getifaddr en0)
    [ -n "$ethernet" ] && echo "$ethernet" && exit 0

    local wireless
    wireless=$(ipconfig getifaddr en1)
    [ -n "$wireless" ] && echo "$wireless" && exit 0

    exit 1
  fi

  # this would be used for debian chroot
  if has "ip"; then
    ip addr | grep "inet 192"
    exit
  fi

  # on my debian chroot this yields internal IP, not unchroot'ed ip
  has "hostname" && hostname -i && exit
}

main
