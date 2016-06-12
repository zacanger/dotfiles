#!/usr/bin/env bash

echo "it's now $(date)"
echo
echo "alarm date and time? "
read date
echo

echo okay! alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo wake up!

while true; do
  /usr/bin/mpv /home/z/Dropbox/z/.alarm.mp3
  sleep 1
done

