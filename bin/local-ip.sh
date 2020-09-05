#!/usr/bin/env bash
set -eu

# silently determine existence of executable
__has() {
  command -v "$1" >/dev/null 2>&1
}

# type localip to get ethernet or wireless ip
__localip() {
  # VERIFIED on OS X El Capitan (10.11)   via wifi
  # VERIFIED on OS X Yosemite   (10.10.5) via wifi
  # VERIFIED on Mavericks
  if __has "ifconfig"; then
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
  if __has "ip"; then
    ip addr | grep "inet 192"
    exit
  fi

  # on my debian chroot this yields internal IP, not unchroot'ed ip
  __has "hostname" && hostname -i && exit
}

__localip
