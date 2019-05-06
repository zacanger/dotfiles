#!/bin/sh

if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
fi
xsetroot -cursor_name left_ptr &
feh --bg-fill ~/Dropbox/z/misc/wall.jpg
xset -dpms
xset s off
xset s noblank
xmodmap -e "clear lock" # disable caps lock switch
xmodmap -e "keysym Caps_Lock = Escape" # set caps_lock as escape
unclutter -root &
redshift -l 40.760780:-111.891045 &
trayer \
  --edge top \
  --align center \
  --SetDockType true \
  --SetPartialStrut true \
  --expand true \
  --width 3 \
  --height 18 \
  --transparent true \
  --tint 0x222222 \
  &
nm-applet &
dropbox start -i &
KEYBASE_AUTOSTART=1 run_keybase &
~/bin/dwm-xsetroot.sh &
exec dwm
# exec ~/Dropbox/work/repos/wmjs/index.js
