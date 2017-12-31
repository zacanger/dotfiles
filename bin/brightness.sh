#!/usr/bin/env bash

# This script changes the brightness level of my screen.  For whatever
# reason the keys have stopped working so I have to do it manually now.
#
# That's fine. I can handle that.
#
# When run without arguments you can press the "u" or the "d" key to
# make it go [u]p or [d]own in brightness.
#
# The projection of it is geometric so you get more granulity in the
# dimmer settings then you get in other tools.
#
# Also, there's a bottom value that is not 0.  This means that you
# won't accidentally put yourself to a blank screen and then have
# to blindly guess your way out of it.
#
port=/sys/devices/*/*/drm/card*/card*/intel_backlight/brightness
amount=`cat $port`
bottom=13

change() {
  count=${2:-1}

  incr=1000

  [ $1 = 'u' ] && incr=1052
  [ $1 = 'd' ] && incr=950

  while [ $count -gt 0 ]; do
    amount=$(( amount * incr / 1000 ))
    [ $1 = 'u' ] && (( amount++ ))
    (( count-- ))
  done

  [ $amount -lt $bottom ] && amount=$bottom

  echo $amount | sudo tee $port >& /dev/null
}

if [ $# -gt 0 ]; then
  change $1 $2
else
  while [ 0 ]; do
    read -n 1 -d '' i
    clear
    incr=1000
    change $i
    echo -n $amount
  done
fi
