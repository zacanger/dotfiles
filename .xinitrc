#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
~/.fehbg &
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
