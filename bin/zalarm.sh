#!/usr/bin/env bash

# what you need: bash, mplayer, an audio file
# change the next line to whatever you want
ALARMPATH=$HOME/Dropbox/z/.alarm/mp3

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
  `which mplayer` $ALARMPATH
  sleep 1
done
