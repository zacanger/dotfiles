#!/bin/sh

if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
fi
xsetroot -cursor_name left_ptr &
~/bin/wallpaper.sh
xset -dpms
xset s off
xset s noblank
xmodmap -e "clear lock" # disable caps lock switch
xmodmap -e "keysym Caps_Lock = Escape" # set caps_lock as escape
redshift -l 40.760780:-111.891045 &
exec i3
# exec ~/Dropbox/work/repos/wmjs/index.js
