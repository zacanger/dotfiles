#!/bin/sh

if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
fi
xsetroot -cursor_name left_ptr
xsetroot -solid "#222"
xset -dpms
xset s off
xset s noblank
xmodmap -e "clear lock"
xmodmap -e "keysym Caps_Lock = Escape"
unclutter -root &
redshift -l 40.760780:-111.891045 -b 0.7 &
dropbox start -i &
exec i3
