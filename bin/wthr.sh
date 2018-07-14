#!/bin/sh

zip=$1
if [ -z $zip ]; then
  zip=84047
fi

curl -s http://wttr.in/$zip
