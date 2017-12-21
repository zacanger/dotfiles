#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
thunar --daemon &
xflux -z 84047
/usr/bin/setxkbmap -option "caps:swapescape"
exec ~/Dropbox/work/repos/wmjs/index.js
