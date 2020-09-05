#!/usr/bin/env bash

# usage: weather.sh zip

METRIC=0 # 0 for F, 1 for C

if [ -z "$1" ] ; then
  echo
  echo "usage: weather.sh zip"
  echo
  exit 0
fi

curl -s http://rss.accuweather.com/rss/liveweather_rss.asp\?metric\=${METRIC}\&locCode\=$1 | perl -ne 'if (/Currently/) {chomp;/\<title\>Currently: (.*)?\<\/title\>/; print "$1"; }'
echo
