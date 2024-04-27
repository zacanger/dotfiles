#!/usr/bin/env bash
set -e

usage() {
    echo 'Usage: mac-switch-keyboard.sh [keeb]'
    echo 'Keebs: 68|mac|reset'
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

if [ "$1" == '68' ]; then
    hidutil property --set '{"UserKeyMapping":[{
        "HIDKeyboardModifierMappingSrc": 0x700000039,
        "HIDKeyboardModifierMappingDst": 0x700000029
    }, {
        "HIDKeyboardModifierMappingSrc": 0x700000029,
        "HIDKeyboardModifierMappingDst": 0x700000035
    }, {
        "HIDKeyboardModifierMappingSrc": 0x700000065,
        "HIDKeyboardModifierMappingDst": 0x7000000E7
    }]}'
elif [ "$1" == 'mac' ]; then
    hidutil property --set '{"UserKeyMapping":[{
        "HIDKeyboardModifierMappingSrc": 0x700000065,
        "HIDKeyboardModifierMappingDst": 0x7000000E7
    }]}'
elif [ "$1" == 'reset' ]; then
    hidutil property --set '{"UserKeyMapping":[]}'
else
    usage
fi
