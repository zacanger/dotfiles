#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
~/bin/wallpaper.sh
xset -dpms
xset s off
xset s noblank
xmodmap -e "clear lock" # disable caps lock switch
xmodmap -e "keysym Caps_Lock = Escape" # set caps_lock as escape
clcl-daemon &
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
