#!/bin/sh
xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
xbindkeys
#exec karmen
#exec sithwm
thunar --daemon &
while true
do
	VOL=$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
	LOCALTIME=$(date +%Z\=%Y-%m-%dT%H:%M)
	OTHERTIME=$(TZ=Europe/London date +%Z\=%H:%M)
	TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"	
	xsetroot -name "dwm <|> vol $VOL <|> temp $TEMP <|> time $LOCALTIME"
	sleep 20s
done &
exec ck-launch-session dbus-launch dwm
