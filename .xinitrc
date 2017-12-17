#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
thunar --daemon &
/usr/bin/setxkbmap -option "caps:swapescape"
exec ~/Dropbox/work/repos/wmjs/index.js
