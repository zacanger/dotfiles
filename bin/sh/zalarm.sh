#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
  echo "it's now $(date)"
  echo "alarm date and time? "
  read date
else
  date="$1"
fi

echo okay! alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo wake up!

while true; do
  `which mplayer` $HOME/Dropbox/z/.alarm.mp3
  sleep 1
done
