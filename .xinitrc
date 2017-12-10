#!/bin/sh

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
thunar --daemon &
/usr/bin/setxkbmap -option "caps:swapescape"
while true
do
  vol=$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
  local_time=$(date +%Z\=%Y-%m-%dT%H:%M)
  other_time=$(TZ=Asia/Seoul date +%Z\=%H:%M)
  temp="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"
  xsetroot -name "dwm <|> vol $vol <|> temp $temp <|> time $local_time"
  sleep 20s
done &
exec dbus-launch dwm
