#!/usr/bin/env bash
set -e

while true; do
  batt=$(cat /sys/class/power_supply/BAT0/capacity)
  disk=$(df -h / | awk '{print $4}' | tail -1)
  datestring=$(date +"%a %Y-%m-%d %H:%M")
  cpuusage=$(mpstat |
    awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d%%",100 - $field) }'
  )
  temperature=$(sensors -f |
    grep Core |
    tr -s ' ' |
    cut -d' ' -f 3 |
    sed 's/[^0-9.]*//g' |
    awk '{ total += $1; count++ } END { print total/count }'
  )
  dropbox=$(dropbox status | head -1)

  echo "$datestring"
  echo "cpu: $cpuusage"
  echo "temp: $temperature"
  echo "batt: $batt"
  echo "disk: $disk"
  echo "db: $dropbox"
  sleep 60
  clear
done
