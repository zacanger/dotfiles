#!/usr/bin/env bash

if (( $# < 2 )); then
  echo 'Usage: alarm <at-time> <msg>'
  exit 1
fi

alarm_path="$HOME/Dropbox/z/.alarm.mp3"
tp="$1"
shift

if [[ ${tp##+*} == "" ]]; then
  tp="now + ${tp#+} min"
fi

cd /
at "$tp" <<EOF
#>> Alarm: $(date +'%F %H:%M' -d "$tp"): $@

for i in {1..3}; do
  play -q "$alarm_path"
  leep 3
done
EOF
