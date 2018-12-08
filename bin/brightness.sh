#!/bin/sh

# little backlight-adjusting script for my netbook

backlight_path=/sys/class/backlight/intel_backlight/brightness
arg="$1"

if [ "$arg" = 'low' ]; then
  echo 2000 > $backlight_path
elif [ "$arg" = 'mid' ]; then
  echo 4000 > $backlight_path
else
  echo 6000 > $backlight_path
fi
