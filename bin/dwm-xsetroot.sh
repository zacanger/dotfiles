#!/usr/bin/env bash

while true; do
  batt="$(cat /sys/class/power_supply/BAT0/capacity)"
  disk="$(df -h / | awk '{print $4}' | tail -1)"
  xsetroot -name "batt: $batt | disk: $disk | $(date)"
  sleep 10
done
