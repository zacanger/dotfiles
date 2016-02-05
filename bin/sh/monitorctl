#!/bin/bash

case $1 in
    off) xrandr --output VGA1 --off ;;
    on) xrandr --output VGA1 --auto --right-of LVDS1 --pos 1280x0 ;;
    toggle)
        if [[ `
            xrandr |
            grep -c '\*+'
        ` -eq 2 ]]; then
            $0 off
        else
            $0 on
        fi
esac
