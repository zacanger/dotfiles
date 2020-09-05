#!/bin/sh

if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
fi
xsetroot -cursor_name left_ptr &
feh --bg-fill ~/Dropbox/z/misc/wall.jpg
xset -dpms
xset s off
xset s noblank
xmodmap -e "clear lock"
xmodmap -e "keysym Caps_Lock = Escape"
unclutter -root &
redshift -l 40.760780:-111.891045 -b 0.7 &
toggletouch.sh
KEYBASE_AUTOSTART=1 run_keybase &
exec i3
