#! /bin/bash

panelkill (){
	killall dzen2
	killall tint2
	killall lxpanel
	killall xfce4-panel
}

action=$(yad --width 300 --title "Panelizer" \
    --image-on-top \
    --image=/usr/share/icons/bbqtux2.png \
    --button="XFCE Panel:2" \
    --button="LXpanel:3" \
    --button="tint2:4" \
    --button="dzen2:6" \
    --button="Kill all:5" \
    --button="gtk-close:1" \
    --text "Choose a panel:")
ret=$?

[[ $ret -eq 1 ]] && exit 0

if [[ $ret -eq 6 ]]; then
   panelkill 
   dzenbar &
fi

if [[ $ret -eq 5 ]]; then
   panelkill
fi

if [[ $ret -eq 2 ]]; then
   panelkill
   xfce4-panel &
fi

if [[ $ret -eq 3 ]]; then
   panelkill
   lxpanel &
fi

if [[ $ret -eq 4 ]]; then
   panelkill
   tint2 &
fi

panelizer

exit 0

