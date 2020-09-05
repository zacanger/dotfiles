#!/usr/bin/env bash
set -e

if [[ $(uname) == 'Darwin' ]]; then
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
else
  sudo systemd-resolve --flush-caches
  sudo service network-manager restart
fi
