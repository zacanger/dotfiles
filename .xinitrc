#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
xflux -z 84047
/usr/bin/setxkbmap -option "caps:swapescape"
~/.fehbg &
clipit
xrandr --output HDMI-1 --auto --left-of LVDS-1
dropbox start
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
