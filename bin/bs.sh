#!/usr/bin/env bash
set -e

if [[ $(uname) == 'Darwin' ]] ; then
    pmset -g batt | sed -n 2p | tr '\t' ' ' | cut -d ' ' -f4-5
else
    if test -e /sys/class/power_supply/BAT0/capacity; then
        cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status >&2
    elif test -e /sys/class/power_supply/BAT1/capacity; then
        cat /sys/class/power_supply/BAT1/capacity /sys/class/power_supply/BAT1/status >&2
    else
        echo 'No battery information found.'
    fi
fi
