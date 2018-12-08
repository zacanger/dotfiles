#!/usr/bin/env bash

while true; do
  xsetroot -name "$(date) batt: $(cat /sys/class/power_supply/BAT0/capacity)"
  sleep 10
done
