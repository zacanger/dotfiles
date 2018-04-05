#!/usr/bin/env bash

if [ $# -lt 1 ];
then
  printf "usage: %s search terms ...\n" "$(basename "$0")" >&2
  exit 1
fi

[ -z "$PAGER" -o ! -t 1 ] && PAGER="cat"

search="$(printf "%s" "$*" \
  | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')"

curl -s --user-agent \
  "Lynx/2.8.8dev.3 libwww-FM/2.14 SSL-MM/1.4.1" \
  --data "q=${search}&kp=-1&kl=us-en" \
  "https://duckduckgo.com/html/" \
  | xpath.py -a href "//a[@href]" \
  | grep "^.*://" \
  | grep -v "https://duckduckgo.com" \
  | grep -v "http://r.duckduckgo.com" \
  | grep -v "http://ad.ddg.gg" \
  | grep -v ".r.msn.com" \
  | grep -v "^$" \
  | uniq \
  | head -n -7
