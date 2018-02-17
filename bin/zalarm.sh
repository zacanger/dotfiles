#!/usr/bin/env bash

# change the next line to whatever you want
alarmpath=$HOME/Dropbox/z/.alarm/mp3

if ! hash mplayer 2>/dev/null
then
  echo 'Please install mplayer!'
  exit 1
fi

if [[ $# -eq 0 ]] ; then
  echo "it's now $(date)"
  echo alarm date and time?
  read date
else
  date="$1"
fi

echo okay! alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo "wake up!"

while true; do
  `which mplayer` $alarmpath
  sleep 1
done
