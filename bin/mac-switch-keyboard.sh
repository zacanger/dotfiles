#!/usr/bin/env bash
set -e

usage() {
    echo 'Usage: mac-switch-keyboard.sh [atom|internal]'
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

if [ "$1" == 'atom' ]; then
    launchctl load -w "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"
elif [ "$1" == 'internal' ]; then
    launchctl unload -w "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"
else
    usage
fi
