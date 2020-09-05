#!/usr/bin/env bash

# needs xinput
# enable/disable touchpad
# find your touchpad name:
# egrep -i 'synap|alps|etps' /proc/bus/input/devices
PAD='SynPS/2 Synaptics TouchPad'
A=$(xinput list-props "$PAD" | sed -n -e 's/.*Device Enabled ([0-9][0-9]*):\t\(.*\)/\1/p')
if [ "$A" -eq 1 ]; then
  xinput set-int-prop "$PAD" "Device Enabled" 8 0
  echo off
else
  xinput set-int-prop "$PAD" "Device Enabled" 8 1
  echo on
fi
