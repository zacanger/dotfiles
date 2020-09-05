#!/bin/sh

# little backlight-adjusting script for my netbook

backlight_path=/sys/class/backlight/intel_backlight/brightness
arg="$1"

if [ "$arg" = 'dark' ]; then
  echo 50 > $backlight_path
elif [ "$arg" = 'low' ]; then
  echo 500 > $backlight_path
elif [ "$arg" = 'mid' ]; then
  echo 2500 > $backlight_path
else
  echo 6000 > $backlight_path
fi
