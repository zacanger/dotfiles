#! /bin/bash

temp=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}') 
mem=$(free -m | grep buffers/cache | sed -e 's/[buffers/cache -+ :]//g' | sed 's/.\{4\}$//')
time=$(date | sed -e 's/EST 2013//g') 
batt=$(cat /sys/class/power_supply/BAT0/capacity)
vol=$(exec amixer get Master | egrep -o "[0-9]+%" | egrep -o "[0-9]*")

#OUTPUT=
$(echo -e $time '|' BATT: $batt '|' RAM: $mem '|' TEMP: $temp '|' VOL: $vol| osd_cat -f -*-terminus-*-*-*-*-13-*-*-*-*-*-*-* -p top -A center -d 4 -o 6 -c brown -l 1)
