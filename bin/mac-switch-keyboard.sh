#!/usr/bin/env bash
set -e

usage() {
    echo 'Usage: mac-switch-keyboard.sh [keeb]'
    echo 'Keebs: atom|internal|ada|reset'
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

if [ "$1" == 'atom' ]; then
    launchctl load -w "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"
elif [ "$1" == 'internal' ]; then
    launchctl unload -w "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"
elif  [ "$1" == 'ada' ]; then
    /usr/bin/hidutil property --set '{"UserKeyMapping":[ { "HIDKeyboardModifierMappingSrc": 0x700000065, "HIDKeyboardModifierMappingDst": 0x7000000E7 } ]}'
elif [ "$1" == 'reset' ]; then
    hidutil property --set '{"UserKeyMapping":[]}'
else
    usage
fi
