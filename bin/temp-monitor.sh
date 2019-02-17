#!/usr/bin/env bash

while :; do
  sensors -f |
    grep Core |
    tr -s ' ' |
    cut -d' ' -f 3 |
    sed 's/[^0-9.]*//g' |
    awk '{ total += $1; count++ } END { print total/count }'

  sleep 30
  clear
done
