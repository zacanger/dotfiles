#!/usr/bin/env bash

# this is the same thing as shalarm.sh
# just basically with my actual preferences
# in it. why? because i'm too lazy to type them out
# each time and too tired to put them in an alias
# right now.

time="$1"
command="$2"
trig=0

while [ $trig = 0 ]; do
  if [ "$(date +%R)" = 07:30  ]; then
    mpv ~/.alarm/lim-kim-paper-bird.mp3
    trig=1
  else
    sleep 5
  fi
done
exit

