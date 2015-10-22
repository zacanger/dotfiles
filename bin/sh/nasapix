#!/bin/bash

PICSOURCE=http://apod.nasa.gov/apod
picname=`wget -q -O - $PICSOURCE/astropix.html | grep '<IMG SRC="' | head -1 | awk -F\" '{ print $2 }' 2>>/dev/null`
if echo $picname | egrep '.jpg' >/dev/null
then
  wget -q -O downloaded.jpg $PICSOURCE/$picname 2>>/dev/null
  mv -f downloaded.jpg desktop.jpg 2>>/dev/null
fi