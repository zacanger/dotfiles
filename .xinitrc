#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
~/bin/wallpaper.sh
xset -dpms
xset s off
xset s noblank
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
