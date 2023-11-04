#!/usr/bin/env bash
set -e

if [[ $(uname) == 'Darwin' ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
else
    resolvectl flush-caches
fi
