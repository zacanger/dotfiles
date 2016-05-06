#!/usr/bin/env bash

# this is a trial

printf "date/time?"

read date

echo okeedokee. alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo WAKE THE FUCK UP

while true; do
  /usr/bin/mpv /home/z/Dropbox/z/.alarm/lim-kim-paper-bird.mp3
  sleep 1
done

