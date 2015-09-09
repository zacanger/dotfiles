#!/usr/bin/env bash

WEATHER="17309"
DEGREES="f"
STOCKS=""
QUOTES="y"
MOTD_VERSION="0.01"

curl -fsH "Accept: text/plain" "http://motd.sh/?v=$MOTD_VERSION&weather=$WEATHER&degrees=$DEGREES&stocks=$STOCKS&quotes=$QUOTES" > ~/.motd.tmp
motd=`cat ~/.motd.tmp`
echo "$motd"
echo "$motd" > ~/.motd
rm ~/.motd.tmp
