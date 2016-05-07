#!/usr/bin/env bash

printf "date/time? "

read date

echo okay! alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo WAKE THE FUCK UP

while true; do
  /usr/bin/mpv /home/z/Dropbox/z/.alarm.mp3
  sleep 1
done

