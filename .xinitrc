#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
thunar --daemon &
xflux -z 84047
/usr/bin/setxkbmap -option "caps:swapescape"
~/.fehbg &
xrandr --output HDMI-1 --auto --left-of LVDS-1
# :exec -3
# exec ~/Dropbox/work/repos/wmjs/index.js
