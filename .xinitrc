#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
~/.fehbg &
xset off
xset s noblank
xset -dpms
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
