#!/bin/bash

action=$(yad --skip-taskbar --width 300 --title "Take Screenshot" \
    --image=/usr/share/icons/bbqtux2.png \
    --image-on-top \
    --button-layout=start \
    --button="Fullscreen:3" \
    --button="Select area:2" \
    --button="Quit:1" \
)
ret=$?

[[ $ret -eq 1 ]] && exit 0

if [[ $ret -eq 2 ]]; then
    screenshot-sel &
    exit 0
fi

if [[ $ret -eq 3 ]]; then
	screenshot &
	exit 0
fi

